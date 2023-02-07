# Changelog

The project is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and [Semantic Versioning](https://semver.org/). All notable changes to this project will be documented in this file.

<a name="Unreleased"></a>
## [Unreleased] - 202X-XX-XX

### Added 

- Option `use_externally_managed_dataflow_sa` to be able to use pre-existing externally-managed service account as Dataflow worker service account. User is expected to apply and manage IAM permissions over external resources (e.g. Cloud KMS key or Secret version) outside of this module.
- Options `pubsub_kms_key_name` and `gcs_kms_key_name` to be able to add encryption of created resources with customer managed keys.

### Removed

- `providers` configuration because it prevents usage of this module with `count` and `for_each`. This module now inherits the default provider configuration from the caller, thereby simplifying module re-usability.

<a name="v1.0.0"></a>
## [v1.0.0] - 2022-12-20

- Initial version
