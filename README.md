# trancee/wasmSID

## Moonbit Version

moon 0.1.20260110 (0e584ac 2026-01-10)

## Setup Moonbit

Add the Moonbit extension in Visual Studio Code

## Install dependencies

moon update
moon install

### Coverage Testing

moon coverage analyze

#### Finding PSID v2
```sh
LANG=C grep -obUaPr "\x50\x53\x49\x44\x00\x02" .
```

#### Finding PSID v3
```sh
LANG=C grep -obUaPr "\x50\x53\x49\x44\x00\x03" .
```

#### Finding PSID v4
```sh
LANG=C grep -obUaPr "\x50\x53\x49\x44\x00\x04" .
```

#### Finding RSID v2
```sh
LANG=C grep -obUaPr "\x52\x53\x49\x44\x00\x02" .
```
