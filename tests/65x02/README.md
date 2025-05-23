# 65x02 Tests

This repository contains tests for various members of the 8-bit 6502 family, provided as an aid to reimplementation.

Each test:
* requires execution of only a single instruction; and
* provides full processor and memory state before and after.

Tests are randomly generated, in substantial volume.

## Methodology

To generate each test set, an implementation is used that:
* conforms to all available documentation, official and third-party;
* passes all other published test sets; and
* has been verified by usage in an emulated machine.

In addition to the standard Git history, test sets are manually versioned to permit for potential future breaking changes in JSON format.

Please report any discrepancies uncovered, either as an issue or via a correcting pull request.
