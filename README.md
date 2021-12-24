# Dockerized `secp256k1` and LibBTC

To build all images.

    ./build

Run `bitcointool` via wrapper.

    ./bitcointool -c pubfrompriv -p KzLzeMteBxy8aPPDCeroWdkYPctafGapqBAmWQwdvCkgKniH9zw6
    # pubkey: 03e69dc540d6bbf1cc5649b7576ca739791d2e078a8b229777f00384b4b4db2073
    # p2pkh address: 19ufF4tB6DbCw24um3P9Gg6hW8xDNgbNeA
    # p2sh-p2wpkh address: 3FYpQjmZGYLjKGjUo7GXGKcHsydJ9ZNDPf

The installed libraries are isolated in `/usr/local` within the `secp256k1` and `libbtc` images.
