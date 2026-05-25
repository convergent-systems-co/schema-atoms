# FIPS 204 — Module-Lattice-Based Digital Signature Standard (ML-DSA)

**FIPS Number:** 204  
**Status:** FINAL  
**Published:** August 2024  
**Algorithm:** ML-DSA (Module-Lattice-Based Digital Signature Algorithm)  
**Predecessor:** CRYSTALS-Dilithium  
**DOI:** [10.6028/NIST.FIPS.204](https://doi.org/10.6028/NIST.FIPS.204)

---

## Abstract

FIPS 204 specifies the Module-Lattice-Based Digital Signature Algorithm (ML-DSA), a post-quantum digital signature scheme whose security rests on the hardness of the Module Learning With Errors (MLWE) problem. ML-DSA is derived from CRYSTALS-Dilithium, selected by NIST following a multi-round public evaluation of post-quantum cryptographic candidates.

The standard defines three parameter sets — ML-DSA-44, ML-DSA-65, and ML-DSA-87 — targeting NIST security levels 2, 3, and 5 respectively. It specifies key generation, signing (in both deterministic and hedged modes), and verification operations.

---

## Background: Post-Quantum Cryptography

Classical digital signature algorithms (RSA, ECDSA) rely on the hardness of integer factorization and discrete logarithm problems. A sufficiently powerful quantum computer running Shor's algorithm can solve both in polynomial time, rendering these algorithms insecure against quantum adversaries.

NIST launched the Post-Quantum Cryptography (PQC) Standardization Project in 2016 to evaluate and standardize quantum-resistant algorithms. FIPS 204 (ML-DSA) is one of the first three standards published, alongside:

- **FIPS 203** — ML-KEM (key encapsulation, based on CRYSTALS-Kyber)
- **FIPS 205** — SLH-DSA (hash-based signatures, based on SPHINCS+)

ML-DSA's security relies on the MLWE problem over rings of polynomials modulo a prime q = 8380417. This problem is widely believed to resist attacks by quantum computers. The module structure balances security strength against key and signature sizes across multiple parameter sets.

---

## Algorithm Overview

ML-DSA follows the Fiat-Shamir with Aborts paradigm adapted for the module lattice setting. The design achieves:

- **EUF-CMA security** (existential unforgeability under chosen message attack)
- **Context string support** for domain separation
- **Deterministic and hedged signing modes**

Context strings (0–255 bytes) bind a signature to a specific application domain. A signature produced with context string A cannot be used in a context expecting string B — the verification will fail.

---

## Parameter Sets

| Parameter Set | Security Level | Comparable To | Public Key | Secret Key | Signature |
|---|---|---|---|---|---|
| ML-DSA-44 | NIST Level 2 | AES-128 | 1312 bytes | 2528 bytes | 2420 bytes |
| ML-DSA-65 | NIST Level 3 | AES-192 | 1952 bytes | 4000 bytes | 3293 bytes |
| ML-DSA-87 | NIST Level 5 | AES-256 | 2592 bytes | 4864 bytes | 4595 bytes |

All three parameter sets share the same algorithmic structure. Differences lie in the module dimensions (k, l), the challenge weight parameter, and the rejection sampling bounds.

---

## Key Operations

### KeyGen()

Generates a public-private key pair (pk, sk).

- The public key `pk` encodes a matrix commitment and a high-order polynomial vector.
- The secret key `sk` encodes the matrix seed, the secret polynomial vectors s1 and s2, and the hint vector t0.
- Keys MUST be generated using an approved random bit generator. The security of all ML-DSA operations depends entirely on the quality of this randomness.

### Sign(sk, message, context_string)

Produces a signature over an arbitrary-length message using the secret key.

**Deterministic mode:** The nonce is derived from the secret key and the message. Signing is reproducible given identical inputs. SHOULD be used when high-quality randomness is unavailable.

**Hedged mode** (RECOMMENDED): The nonce is derived from the secret key, a 256-bit random value, and the message. Hedged signing provides resilience against fault attacks and offers additional protection if the secret key is partially compromised.

The signing loop uses rejection sampling (Fiat-Shamir with Aborts): if a candidate signature fails statistical bounds, the loop restarts. This is expected behavior and is essential to the zero-knowledge property of the scheme.

### Verify(pk, message, signature, context_string)

Verifies a signature against a public key and message. Returns a boolean.

A signature is accepted only when:
1. The hint vector `h` has no more than `omega` non-zero entries.
2. The response vector `z` has coefficients within the required bound.
3. The recomputed challenge matches the challenge carried in the signature.

The context string supplied to Verify() MUST be identical to the one supplied to Sign(); a mismatch causes verification to return false.

Implementations MUST call Verify() before acting on any data protected by the signature.

---

## Use in schema-atoms

ML-DSA-65 is the required signing algorithm for atom signatures in the schema-atoms catalog (`ATOMS.yml: signing.required_algorithms: ["ml-dsa-65"]`).

**Why ML-DSA-65:**

- **Security margin:** NIST Level 3 (AES-192 equivalent) provides a strong security margin beyond the minimum, without requiring the largest key and signature sizes of ML-DSA-87.
- **Size profile:** The 1952-byte public key and 3293-byte signature are well-suited for application-layer document signing, where sizes are carried in structured TOML/YAML envelopes rather than bandwidth-constrained network packets.
- **Library availability:** ML-DSA-65 is among the most widely implemented parameter sets in cryptographic libraries following the FIPS 204 publication.

All three parameter sets are accepted (`signing.accepted_algorithms`), but new atom signatures MUST use ML-DSA-65 unless the catalog maintainer approves an exception.

Atom signing quorum for the `fips` class: `1 of role:catalog-maintainer` (see `ATOMS.yml signing.quorum_rules.fips`).

---

## Security Considerations

**EUF-CMA:** ML-DSA achieves existential unforgeability under chosen message attack. An adversary with signing oracle access cannot forge a valid signature on a new message except with negligible probability.

**Context binding:** The context string is hashed into the message representative during signing, cryptographically binding the signature to its intended domain. Applications MUST use distinct context strings for distinct protocols.

**Secret key protection:** Secret keys MUST NOT be embedded in artifacts, source code, or version control. They MUST be stored in a secure key management facility (hardware security module, OS keychain, or secrets vault) and rotated when compromise is suspected.

**Randomness quality:** The security of hedged signing and of key generation depends on the quality of the random bit generator. Implementations MUST use an approved DRBG (NIST SP 800-90A) seeded from a high-entropy source.

**Quantum resistance:** ML-DSA is designed to resist attacks by both classical and quantum computers. The best known quantum attacks against MLWE (for ML-DSA-65 parameters) require resources comparable to breaking AES-192.

---

## References

- **NIST FIPS 204** — "Module-Lattice-Based Digital Signature Standard." August 2024. <https://doi.org/10.6028/NIST.FIPS.204>
- **CRYSTALS-Dilithium** — Ducas, L. et al. "CRYSTALS-Dilithium Algorithm Specifications and Supporting Documentation." Version 3.1, 2021. *(Predecessor to FIPS 204.)*
- **NIST PQC Project** — <https://csrc.nist.gov/projects/post-quantum-cryptography>
- **FIPS 203** — "Module-Lattice-Based Key-Encapsulation Mechanism Standard." August 2024. *(ML-KEM / CRYSTALS-Kyber — companion standard.)*
- **FIPS 205** — "Stateless Hash-Based Digital Signature Standard." August 2024. *(SLH-DSA / SPHINCS+ — companion standard.)*
