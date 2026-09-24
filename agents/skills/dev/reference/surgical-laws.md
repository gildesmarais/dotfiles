# Surgical laws

Load when introducing or changing tests, dual delivery paths, or acceptance criteria.

- Test flight height: pure unit for domain/math, focused fakes for components, real I/O for integration; frontend: real DOM/a11y via `modern-web-guidance` and `chrome-devtools` over mocks. Decompose suites by layer. No ad-hoc sleep polling — bounded condition waits. Test friction diagnoses a seam defect.
- Introducing or widening a dual delivery path for one derived fact → discriminating parity (or failure-matrix) test before cutover.
- Acceptance names observable outcomes, not internal field inventories.
- One-surface incident rule: drive-by edits on a second surface travel with the revert.
