# Changelog

The project is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and [Semantic Versioning](https://semver.org/). All notable changes to this project will be documented in this file.

<a name="Unreleased"></a>
## [Unreleased] - 202X-XX-XX

### Added 

- Option `use_externally_managed_dataflow_sa` to be able to use pre-existing externally-managed service account as Dataflow worker service account. User is expected to apply and manage IAM permissions over external resources (e.g. Cloud KMS key or Secret version) outside of this module.
- Enable uniform bucket-level access for the temporary Cloud Storage bucket used by Dataflow pipeline. This change disables ACLs for individual objects in this bucket, in favor for a uniform access control over entire bucket and IAM-based security features (e.g. Domain Restricted Sharing, IAM Conditions).

### Removed

- `providers` configuration because it prevents usage of this module with `count` and `for_each`. This module now inherits the default provider configuration from the caller, thereby simplifying module re-usability.

### Fixed

- Removed hardcoded project numbers in log panels in dashboard's JSON description

<a name="v1.0.0"></a>
## [v1.0.0] - 2022-12-20

- Initial version
