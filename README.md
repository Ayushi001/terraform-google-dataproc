# terraform-google-dataproc

## Description

The Terraform module handles the creation of Dataproc Cluster on Google Cloud.

## Assumptions and prerequisites
This module assumes that below mentioned prerequisites are in place before consuming the module.

- To deploy this blueprint you must have an active billing account and billing permissions.
- APIs are enabled.
- Permissions are available.

## Documentation

[Dataproc Cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dataproc_cluster)

## Usage

Basic usage of this module is as follows:

```hcl
module "dataproc" {
  source = "terraform-google-modules/dataproc/google"
  version = "~> 0.1"
  project_id = "<PROJECT ID>"
  name       = "simple-example-cluster"
  region     = "us-central1"
}
```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_config | Allows you to configure various aspects of the cluster. | <pre>object({<br>    staging_bucket = optional(string)<br>    temp_bucket    = optional(string)<br>    gce_cluster_config = optional(object({<br>      zone                   = optional(string)<br>      network                = optional(string)<br>      subnetwork             = optional(string)<br>      service_account        = optional(string)<br>      service_account_scopes = optional(list(string))<br>      tags                   = optional(list(string), [])<br>      internal_ip_only       = optional(bool)<br>      metadata               = optional(map(string), {})<br>      reservation_affinity = optional(object({<br>        consume_reservation_type = string<br>        key                      = string<br>        values                   = list(string)<br>      }))<br>      node_group_affinity = optional(object({<br>        node_group_uri = string<br>      }))<br>      shielded_instance_config = optional(object({<br>        enable_secure_boot          = bool<br>        enable_vtpm                 = bool<br>        enable_integrity_monitoring = bool<br>      }))<br>      confidential_instance_config = optional(object({<br>        enable_confidential_compute = bool<br>      }))<br>    }))<br>    master_config = optional(object({<br>      num_instances    = number<br>      machine_type     = optional(string)<br>      min_cpu_platform = optional(string)<br>      image_uri        = optional(string)<br>      disk_config = optional(object({<br>        boot_disk_type    = string<br>        boot_disk_size_gb = number<br>        num_local_ssds    = number<br>      }))<br>      accelerators = optional(list(object({<br>        accelerator_type  = string<br>        accelerator_count = number<br>      })))<br>    }))<br>    worker_config = optional(object({<br>      num_instances    = number<br>      machine_type     = optional(string)<br>      min_cpu_platform = optional(string)<br>      disk_config = optional(object({<br>        boot_disk_type    = string<br>        boot_disk_size_gb = number<br>        num_local_ssds    = number<br>      }))<br>      image_uri = optional(string)<br>      accelerators = optional(list(object({<br>        accelerator_type  = string<br>        accelerator_count = number<br>      })))<br>    }))<br>    preemptible_worker_config = optional(object({<br>      num_instances  = number<br>      preemptibility = string<br>      disk_config = optional(object({<br>        boot_disk_type    = string<br>        boot_disk_size_gb = number<br>        num_local_ssds    = number<br>      }))<br>    }))<br>    software_config = optional(object({<br>      image_version       = optional(string)<br>      override_properties = optional(map(string))<br>      optional_components = optional(list(string))<br>    }))<br>    security_config = optional(object({<br>      kerberos_config = optional(object({<br>        cross_realm_trust_admin_server        = optional(string)<br>        cross_realm_trust_kdc                 = optional(string)<br>        cross_realm_trust_realm               = optional(string)<br>        cross_realm_trust_shared_password_uri = optional(string)<br>        enable_kerberos                       = optional(bool)<br>        kdc_db_key_uri                        = optional(string)<br>        key_password_uri                      = optional(string)<br>        keystore_uri                          = optional(string)<br>        keystore_password_uri                 = optional(string)<br>        kms_key_uri                           = string<br>        realm                                 = optional(string)<br>        root_principal_password_uri           = string<br>        tgt_lifetime_hours                    = optional(number)<br>        truststore_password_uri               = optional(string)<br>        truststore_uri                        = optional(string)<br>      }))<br>    }))<br>    autoscaling_config = optional(object({<br>      policy_uri = string<br>    }))<br>    initialization_action = optional(object({<br>      script      = string<br>      timeout_sec = optional(number)<br>    }))<br>    encryption_config = optional(object({<br>      kms_key_name = string<br>    }))<br>    lifecycle_config = optional(object({<br>      idle_delete_ttl  = optional(string)<br>      auto_delete_time = optional(string)<br>    }))<br>    endpoint_config = optional(object({<br>      enable_http_port_access = bool<br>    }))<br>    dataproc_metric_config = optional(object({<br>      metrics = list(object({<br>        metric_source    = string<br>        metric_overrides = optional(list(string))<br>      }))<br>    }))<br>    metastore_config = optional(object({<br>      dataproc_metastore_service = string<br>    }))<br>  })</pre> | `null` | no |
| graceful\_decommission\_timeout | Allows graceful decommissioning when you change the number of worker nodes directly through a terraform apply. Does not affect auto scaling decommissioning from an autoscaling policy. Graceful decommissioning allows removing nodes from the cluster without interrupting jobs in progress. Timeout specifies how long to wait for jobs in progress to finish before forcefully removing nodes (and potentially interrupting jobs). Default timeout is 0 (for forceful decommission), and the maximum allowed timeout is 1 day. | `string` | `"0"` | no |
| labels | The list of labels (key/value pairs) configured on the resource through Terraform and to be applied to instances in the cluster. | `map(string)` | `{}` | no |
| name | The name of the Dataproc Cluster. | `string` | n/a | yes |
| project\_id | The ID of the project in which the Dataproc Cluster belongs. | `string` | n/a | yes |
| region | The region in which the cluster and associated nodes will be created. | `string` | n/a | yes |
| virtual\_cluster\_config | Allows you to configure a virtual Dataproc on GKE cluster | <pre>object({<br>    staging_bucket = optional(string)<br>    auxiliary_services_config = optional(object({<br>      metastore_config = optional(object({<br>        dataproc_metastore_service = string<br>      }))<br>      spark_history_server_config = optional(object({<br>        dataproc_cluster = string<br>      }))<br>    }))<br>    kubernetes_cluster_config = optional(object({<br>      kubernetes_namespace = optional(string)<br>      kubernetes_software_config = object({<br>        component_version = map(string)<br>        properties        = optional(map(string))<br>      })<br>      gke_cluster_config = object({<br>        gke_cluster_target = optional(string)<br>        node_pool_target = optional(object({<br>          node_pool = string<br>          roles     = list(string)<br>          node_pool_config = optional(object({<br>            autoscaling = optional(object({<br>              min_node_count = optional(number)<br>              max_node_count = optional(number)<br>            }))<br>            config = optional(object({<br>              machine_type     = optional(string)<br>              preemptible      = optional(bool)<br>              local_ssd_count  = optional(number)<br>              min_cpu_platform = optional(string)<br>              spot             = optional(bool)<br>            }))<br>            locations = optional(list(string))<br>          }))<br>        }))<br>      })<br>    }))<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_id | The ID of the Dataproc cluster |
| cluster\_name | The name of the Dataproc cluster |
| cluster\_project | The project ID of the Dataproc cluster |
| cluster\_region | The region of the Dataproc cluster |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.0

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Dataproc Admin: `roles/dataproc.admin`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Google Cloud Storage JSON API: `dataproc.googleapis.com`

The [Project Factory module][project-factory-module] can be used to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
