use ark_bls12_381::Bls12_381;
use ark_ec::pairing::Pairing;
use ark_std::{rand::rngs::StdRng, UniformRand};
use blake2::Blake2b512;
use schnorr_pok::compute_random_oracle_challenge;

use crate::{
    mercurial_sig::PublicKey,
    protego::{
        issuance::{Credential, SignatureRequestProtocol},
        keys::{
            IssuerPublicKey, IssuerSecretKey, PreparedIssuerPublicKey, UserPublicKey, UserSecretKey,
        },
        show::signer_hidden_with_policy::{
            CredentialShowProtocolWithDelegationPolicy, DelegationPolicyPublicKey,
            DelegationPolicySecretKey,
        },
    },
    set_commitment::{PreparedSetCommitmentSRS, SetCommitmentSRS},
};

use super::signer_hidden_with_policy::{CredentialShowWithDelegationPolicy, DelegationPolicyProof};

type Fr = <Bls12_381 as Pairing>::ScalarField;

// 1. Issuer's key generation
pub fn setup_issuer(
    rng: &mut StdRng,
    set_comm_srs: &SetCommitmentSRS<Bls12_381>,
) -> (IssuerSecretKey<Bls12_381>, IssuerPublicKey<Bls12_381>) {
    let isk = IssuerSecretKey::<Bls12_381>::new::<StdRng>(
        rng, false, // revocation無し
        false, // auditable無し
    )
    .unwrap();
    let ipk = IssuerPublicKey::new(&isk, set_comm_srs.get_P2());
    (isk, ipk)
}

// 2. Verifier's key generation
pub fn setup_verifier(
    rng: &mut StdRng,
    set_comm_srs: &SetCommitmentSRS<Bls12_381>,
) -> (
    DelegationPolicySecretKey<Bls12_381>,
    DelegationPolicyPublicKey<Bls12_381>,
) {
    let policy_sk = DelegationPolicySecretKey::new(rng, 3).unwrap();
    let policy_pk = DelegationPolicyPublicKey::new(&policy_sk, set_comm_srs.get_P1());
    (policy_sk, policy_pk)
}

// 3. User's key generation
pub fn setup_user(
    rng: &mut StdRng,
    supports_revocation: bool,
    set_comm_srs: &SetCommitmentSRS<Bls12_381>,
) -> (UserSecretKey<Bls12_381>, UserPublicKey<Bls12_381>) {
    let usk = UserSecretKey::new(rng, supports_revocation);
    let upk = UserPublicKey::new(&usk, set_comm_srs.get_P1());
    (usk, upk)
}

// 4. Generate credential
pub fn create_credential(
    rng: &mut StdRng,
    attributes: Vec<Fr>,
    isk: &IssuerSecretKey<Bls12_381>,
    ipk: &IssuerPublicKey<Bls12_381>,
    usk: &UserSecretKey<Bls12_381>,
    upk: &UserPublicKey<Bls12_381>,
    set_comm_srs: &SetCommitmentSRS<Bls12_381>,
) -> Credential<Bls12_381> {
    let prep_set_comm_srs = PreparedSetCommitmentSRS::from(set_comm_srs.clone());
    let prep_ipk = PreparedIssuerPublicKey::from(ipk.clone());

    // 署名リクエストプロトコルの初期化
    let sig_req_p = SignatureRequestProtocol::init(
        rng,
        usk,
        false, // auditable無し
        set_comm_srs.get_P1(),
    );

    // チャレンジの生成
    let mut chal_bytes = vec![];
    sig_req_p
        .challenge_contribution(upk, set_comm_srs.get_P1(), None, &mut chal_bytes)
        .unwrap();

    // TODO: チャレンジは入力から計算する
    let challenge = compute_random_oracle_challenge::<Fr, Blake2b512>(&chal_bytes);

    // 署名リクエストの生成
    let (sig_req, sig_req_opn) = sig_req_p
        .gen_request(rng, attributes.clone(), usk, &challenge, set_comm_srs)
        .unwrap();

    // 署名リクエストの検証
    sig_req
        .verify(
            attributes.clone(),
            upk,
            &challenge,
            None,
            None,
            prep_set_comm_srs.clone(),
        )
        .unwrap();

    // 署名の生成
    let sig = sig_req
        .clone()
        .sign(
            rng,
            isk,
            None, // auditable無し
            None, // auditable無し
            set_comm_srs.get_P1(),
            set_comm_srs.get_P2(),
        )
        .unwrap();

    // クレデンシャルの生成
    Credential::new(
        sig_req,
        sig_req_opn,
        sig,
        attributes,
        prep_ipk,
        None, // auditable無し
        None, // auditable無し
        set_comm_srs.get_P1(),
        prep_set_comm_srs.prepared_P2,
    )
    .unwrap()
}

// 5. Verifier policy generation
pub fn create_verifier_policy(
    rng: &mut StdRng,
    policy_sk: &DelegationPolicySecretKey<Bls12_381>,
    issuers: Vec<IssuerPublicKey<Bls12_381>>,
    set_comm_srs: &SetCommitmentSRS<Bls12_381>,
) -> Vec<DelegationPolicyProof<Bls12_381>> {
    issuers
        .into_iter()
        .map(|ipk| {
            // 発行者の公開鍵に対して署名を生成
            let policy_sig = policy_sk
                .sign_public_key(rng, &ipk, set_comm_srs.get_P1(), set_comm_srs.get_P2())
                .unwrap();

            // ランダムな値でpublic keyとsignatureを再ランダム化
            let rho = Fr::rand(rng);
            let (new_sig, new_key) = policy_sig.change_rep(rng, &rho, &ipk.public_key.0);

            // 再ランダム化された公開鍵を作成
            let randomized_pk = IssuerPublicKey {
                public_key: PublicKey(new_key),
                supports_revocation: ipk.supports_revocation,
                supports_audit: ipk.supports_audit,
            };

            // DelegationPolicyProofを生成
            DelegationPolicyProof {
                randomized_pk,
                signature: new_sig,
            }
        })
        .collect()
}

// 6. Show credential
pub fn show_credential(
    rng: &mut StdRng,
    credential: &Credential<Bls12_381>,
    disclosed_attributes: Vec<Fr>,
    issuer_pk: &IssuerPublicKey<Bls12_381>,
    policy_sig: crate::mercurial_sig::SignatureG2<Bls12_381>,
    set_comm_srs: &SetCommitmentSRS<Bls12_381>,
) -> CredentialShowWithDelegationPolicy<Bls12_381> {
    // DelegationPolicyProofを直接生成せず、既存のものを使用
    let show_proto = CredentialShowProtocolWithDelegationPolicy::init(
        rng,
        credential.clone(),
        disclosed_attributes,
        issuer_pk,
        &policy_sig,
        None,
        None,
        set_comm_srs,
    )
    .unwrap();

    // チャレンジを生成する際のcontextを保存
    let nonce = vec![1, 2, 3]; // 固定のnonceを使用
    let mut chal_bytes = vec![];
    show_proto
        .challenge_contribution(
            None,
            None,
            None,
            set_comm_srs.get_P1(),
            &nonce, // 同じnonceを使用
            &mut chal_bytes,
        )
        .unwrap();

    // 同じチャレンジを使用
    let challenge = compute_random_oracle_challenge::<Fr, Blake2b512>(&chal_bytes);
    show_proto.gen_show(None, &challenge).unwrap()
}

#[cfg(test)]
mod tests {
    use super::*;
    use ark_std::rand::SeedableRng;

    #[test]
    fn test_protego_complete_flow() {
        let mut rng = StdRng::seed_from_u64(0u64);

        println!("\n1. Setting up system parameters...");
        let (set_comm_srs, _) = SetCommitmentSRS::<Bls12_381>::generate_with_random_trapdoor::<
            StdRng,
            Blake2b512,
        >(&mut rng, 10, Some("test".as_bytes()));
        println!("✓ System parameters initialized");

        println!("\n2. Setting up issuers...");
        let (isk1, ipk1) = setup_issuer(&mut rng, &set_comm_srs);
        let (_isk2, ipk2) = setup_issuer(&mut rng, &set_comm_srs);
        println!("✓ Issuers created");
        println!("  - Issuer 1 public key size: {}", ipk1.public_key.size());
        println!("  - Issuer 2 public key size: {}", ipk2.public_key.size());
        println!("  - Issuer 1 public key: {:?}", ipk1.public_key.0);

        println!("\n3. Setting up verifier...");
        let (policy_sk, policy_pk) = setup_verifier(&mut rng, &set_comm_srs);
        println!("✓ Verifier created");
        println!("  - Policy public key: {:?}", policy_pk.0);

        println!("\n4. Setting up user...");
        let (usk, upk) = setup_user(&mut rng, false, &set_comm_srs);
        println!("✓ User created");
        println!("  - User public key: {:?}", upk.0);

        println!("\n5. Creating attributes...");
        let attributes = vec![Fr::rand(&mut rng), Fr::rand(&mut rng)];
        println!("✓ Created {} attributes", attributes.len());
        for (i, attr) in attributes.iter().enumerate() {
            println!("  - Attribute {}: {:?}", i, attr);
        }

        println!("\n6. Issuing credential...");
        let start = std::time::Instant::now();
        let credential = create_credential(
            &mut rng,
            attributes.clone(),
            &isk1,
            &ipk1,
            &usk,
            &upk,
            &set_comm_srs,
        );
        let issuance_time = start.elapsed();
        println!("✓ Credential issued");
        println!("  - Issuance time: {:?}", issuance_time);
        println!("  - Credential signature: {:?}", credential.signature);

        println!("\n7. Creating verifier policies...");
        let start = std::time::Instant::now();
        let policies = create_verifier_policy(
            &mut rng,
            &policy_sk,
            vec![ipk1.clone(), ipk2.clone()],
            &set_comm_srs,
        );
        let policy_time = start.elapsed();
        println!("✓ Created {} issuer policies", policies.len());
        println!("  - Policy creation time: {:?}", policy_time);
        for (i, policy) in policies.iter().enumerate() {
            println!("  - Policy {} signature: {:?}", i, policy.signature);
            println!(
                "  - Policy {} randomized pk: {:?}",
                i, policy.randomized_pk.public_key.0
            );
        }

        println!("\n8. Preparing selective disclosure...");
        let disclosed_attrs = vec![attributes[0]];
        println!(
            "  - Disclosing {} out of {} attributes",
            disclosed_attrs.len(),
            attributes.len()
        );
        println!("  - Disclosed attributes: {:?}", disclosed_attrs);

        println!("\n9. Generating credential proof...");
        let start = std::time::Instant::now();
        let show = show_credential(
            &mut rng,
            &credential,
            disclosed_attrs.clone(),
            &policies[0].randomized_pk,
            policies[0].signature.clone(),
            &set_comm_srs,
        );
        let show_time = start.elapsed();
        println!("✓ Credential proof generated");
        println!("  - Proof generation time: {:?}", show_time);
        println!("  - Proof details:");
        println!("    * Credential show: {:?}", show.credential_show);
        println!(
            "    * Public key anonymity proof: {:?}",
            show.pubkey_anonymity_proof
        );

        println!("\n10. Verifying proof...");
        let start = std::time::Instant::now();
        let result = show.verify(
            &compute_random_oracle_challenge::<Fr, Blake2b512>(&vec![1, 2, 3]),
            disclosed_attrs,
            &policy_pk,
            None,
            set_comm_srs,
        );
        let verify_time = start.elapsed();
        println!("✓ Verification result: {:?}", result.is_ok());
        println!("  - Verification time: {:?}", verify_time);

        assert!(result.is_ok());
        println!("\n✓ All tests completed successfully");
    }

    #[test]
    fn test_multiple_attributes_disclosure() {
        let mut rng = StdRng::seed_from_u64(0u64);

        println!("\nTest: Multiple attribute disclosure scenarios");

        // System setup
        let (set_comm_srs, _) = SetCommitmentSRS::<Bls12_381>::generate_with_random_trapdoor::<
            StdRng,
            Blake2b512,
        >(&mut rng, 10, Some("test".as_bytes()));

        // Setup participants
        let (isk, ipk) = setup_issuer(&mut rng, &set_comm_srs);
        let (policy_sk, policy_pk) = setup_verifier(&mut rng, &set_comm_srs);
        let (usk, upk) = setup_user(&mut rng, false, &set_comm_srs);

        // Test with different numbers of attributes
        let attribute_counts = vec![2, 4, 6, 8];
        for count in attribute_counts {
            println!("\nNumber of attributes: {}", count);

            // Generate attributes
            let attributes = (0..count).map(|_| Fr::rand(&mut rng)).collect::<Vec<_>>();
            println!("  Generated attributes: {:?}", attributes);

            // Issue credential
            let credential = create_credential(
                &mut rng,
                attributes.clone(),
                &isk,
                &ipk,
                &usk,
                &upk,
                &set_comm_srs,
            );
            println!("  Credential signature: {:?}", credential.signature);

            // Create policies
            let policies =
                create_verifier_policy(&mut rng, &policy_sk, vec![ipk.clone()], &set_comm_srs);
            println!("  Policy signature: {:?}", policies[0].signature);

            // Test different disclosure patterns
            for disclosed_count in 1..=count {
                let disclosed_attrs = attributes[0..disclosed_count].to_vec();
                println!(
                    "\n  Disclosing {} attributes: {:?}",
                    disclosed_count, disclosed_attrs
                );

                let start = std::time::Instant::now();
                let show = show_credential(
                    &mut rng,
                    &credential,
                    disclosed_attrs.clone(),
                    &policies[0].randomized_pk,
                    policies[0].signature.clone(),
                    &set_comm_srs,
                );
                let show_time = start.elapsed();
                println!("    - Proof generation time: {:?}", show_time);
                println!("    - Proof details: {:?}", show.credential_show);

                let start = std::time::Instant::now();
                let result = show.verify(
                    &compute_random_oracle_challenge::<Fr, Blake2b512>(&vec![1, 2, 3]),
                    disclosed_attrs,
                    &policy_pk,
                    None,
                    set_comm_srs.clone(),
                );
                let verify_time = start.elapsed();
                println!("    - Verification time: {:?}", verify_time);
                println!("    - Verification result: {:?}", result.is_ok());

                assert!(result.is_ok());
            }
        }
    }
}
