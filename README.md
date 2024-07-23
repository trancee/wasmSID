# trancee/wasmSID

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
