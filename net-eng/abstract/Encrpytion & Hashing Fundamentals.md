Title | Encrpytion & Hashing Fundamentals
--- | ---
Contributor | Daniel Hurley [@daniel-hurley](https://github.com/daniel-hurley/)
Date | 07-19-2023

## Let’s start with hashing

Hashing is a one-way mathematical function used to provide data integrity and authenticity. Data of any length is used for the input to the algorithm. The output of the algorithm is a fixed length hash (known as a digest). The length of the hash is based on the bit size of the algorithm. Since the algorithm is one-way, it is impossible to reverse engineer. Sometimes the length of the input of the hashing algorithm is more than the bit size of the hash itself – which creates scenarios where different inputs to the same algorithm can cause the hash to be the same. This is where a Collision Attack can come into play for hashing algorithms. A Collision attack is simply using another key to result in the same output by the hashing algorithm. By increasing the bit size of the hashing algorithm, you make it much harder for a Collision Attack to crack.

Hashing algorithms:

- MD5 (128 bit)
- SHA1 (160 bit)
- SHA2 (224, 256, 384, 512 bit)

Hashing alone is very easy to bypass with a man in the middle attack, as the packet information can be replaced. The receiver of the packet will not know the difference because the input of the hash because it’s simply just packet bits. It is unknown to the receiver if it was changed, as the hash will be the same.

Hashed Message Authentication Code (HMAC) uses hashing as a key that is only known between the sender and receiver – which will prevent a man in the middle attack described above. Instead of using packet bits as the hash input (alone), it uses a pre-configured key that is only known to sender and receiver. The input of the hash is the packet bits, AND the secret key.  Devices using HMAC take the plain input of the hash, and adds on the key, for each transaction.

## And now encryption algorithms

Encryption is a two-way mathematical function used to provide data confidentiality. The input of the encryption algorithm is the clear-text packet AND the secret key (either asymmetric or symmetric). The output of the algorithm is known as the cipher text. Once a device receives the cipher text on the other side of the encrypted tunnel, it uses the cipher text plus the secret key as the input of the algorithm. The output is the plain text packet. Asymmetric encryption uses a public and private key pair (for each direction of traffic) to encrypt and decrypt the data.

### Symmetric encryption – Uses the same key for encryption and decryption

- Also known as shared key encryption
- More efficient, cheaper to perform on hardware
- Typical length 56-512 bits

### Symmetric Algorithms

*DES* – Data Encryption Standard (64-bit key, only 56 bit used for encryption)

*3DES* – Triple Data Encryption Standard (168-bit key, uses 3 keys of 56-bit)

*AES* – Advanced Encryption Standard (3 Versions: 128, 192, and 256 bit keys)

*SEAL*, *IDEA*, *Blowfish*, *Serpent*

### Asymmetric encryption – Different key is used for encryption and decryption

- Also known as public key encryption
- computationally expensive to perform on hardware
- key length series varies between 512 bit to 32768 bit

### Asymmetric Algorithms:

*RSA* – Rivest Shamir Adleman

*DSA* – Digital Signature Algorithm

*DH* – Diffie Hellman Algorithm

*ECC* – Eliptic Curve Cryptography (ECDH, ECDSA)