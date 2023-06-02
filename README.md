# PRESENT_AVR

### Optimized Implementation of PRESENT on 8-bit AVR (ATmega128)

### Test vectors for PRESENT with an 80-bit key
##### plaintext   = 00000000 00000000
##### key         = 00000000 00000000 0000
##### ciphertext  = 5579c138 7b228455

#### This is a code that has been encrypted after pre-calculating the key schedule and the P operation performed on some round keys. PRESENT-80 and PRESENT-128 have the same number of rounds (and the same number of round keys), so if you pre-calculate the round keys, you can use the encryption function together.


### reference
1. Bogdanov, A., Knudsen, L.R., Leander, G., Paar, C., Poschmann, A., Robshaw, M.J.B., Seurin, Y., Vikkelsoe, C.: PRESENT: an ultra-lightweight block cipher. In: CHES. Lecture Notes in Computer Science, vol. 4727, pp. 450–466. Springer (2007)
2. Reis, T.B., Aranha, D.F., López, J. PRESENT runs fast. In Proceedings of the International Conference on Cryptographic Hardware and Embedded Systems, Taipei, Taiwan, 25–28 September 2017; Springer: Berlin/Heidelberg, Germany, 2017; pp. 644–664.
3. Kwon H, Kim YB, Seo SC, Seo H. High-Speed Implementation of PRESENT on AVR Microcontroller. Mathematics. 2021; 9(4):374.  https://github.com/solowal/PRESENT_AVR