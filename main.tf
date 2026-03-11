/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

data "google_compute_default_service_account" "default" {
  project = var.project_id
}

resource "google_project_iam_member" "dataproc_worker" {
  project = var.project_id
  role    = "roles/dataproc.worker"
  member  = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}


resource "google_dataproc_cluster" "cluster" {
  name    = var.name
  project = var.project_id
  region  = var.region
  labels  = var.labels

  graceful_decommission_timeout = var.graceful_decommission_timeout

  # ==========================================
  # Standard Dataproc on GCE (cluster_config)
  # ==========================================
  dynamic "cluster_config" {
    for_each = var.cluster_config != null ? [var.cluster_config] : []
    content {
      staging_bucket = cluster_config.value.staging_bucket
      temp_bucket    = cluster_config.value.temp_bucket

      dynamic "gce_cluster_config" {
        for_each = cluster_config.value.gce_cluster_config != null ? [cluster_config.value.gce_cluster_config] : []
        content {
          zone                   = gce_cluster_config.value.zone
          network                = gce_cluster_config.value.network
          subnetwork             = gce_cluster_config.value.subnetwork
          service_account        = gce_cluster_config.value.service_account
          service_account_scopes = gce_cluster_config.value.service_account_scopes
          tags                   = gce_cluster_config.value.tags
          internal_ip_only       = gce_cluster_config.value.internal_ip_only
          metadata               = gce_cluster_config.value.metadata

          dynamic "reservation_affinity" {
            for_each = gce_cluster_config.value.reservation_affinity != null ? [gce_cluster_config.value.reservation_affinity] : []
            content {
              consume_reservation_type = reservation_affinity.value.consume_reservation_type
              key                      = reservation_affinity.value.key
              values                   = reservation_affinity.value.values
            }
          }

          dynamic "node_group_affinity" {
            for_each = gce_cluster_config.value.node_group_affinity != null ? [gce_cluster_config.value.node_group_affinity] : []
            content {
              node_group_uri = node_group_affinity.value.node_group_uri
            }
          }

          dynamic "shielded_instance_config" {
            for_each = gce_cluster_config.value.shielded_instance_config != null ? [gce_cluster_config.value.shielded_instance_config] : []
            content {
              enable_secure_boot          = shielded_instance_config.value.enable_secure_boot
              enable_vtpm                 = shielded_instance_config.value.enable_vtpm
              enable_integrity_monitoring = shielded_instance_config.value.enable_integrity_monitoring
            }
          }

          dynamic "confidential_instance_config" {
            for_each = gce_cluster_config.value.confidential_instance_config != null ? [gce_cluster_config.value.confidential_instance_config] : []
            content {
              enable_confidential_compute = confidential_instance_config.value.enable_confidential_compute
            }
          }
        }
      }

      dynamic "master_config" {
        for_each = cluster_config.value.master_config != null ? [cluster_config.value.master_config] : []
        content {
          num_instances    = master_config.value.num_instances
          machine_type     = master_config.value.machine_type
          min_cpu_platform = master_config.value.min_cpu_platform
          image_uri        = master_config.value.image_uri

          dynamic "disk_config" {
            for_each = master_config.value.disk_config != null ? [master_config.value.disk_config] : []
            content {
              boot_disk_type    = disk_config.value.boot_disk_type
              boot_disk_size_gb = disk_config.value.boot_disk_size_gb
              num_local_ssds    = disk_config.value.num_local_ssds
            }
          }

          dynamic "accelerators" {
            for_each = master_config.value.accelerators != null ? master_config.value.accelerators : []
            content {
              accelerator_type  = accelerators.value.accelerator_type
              accelerator_count = accelerators.value.accelerator_count
            }
          }
        }
      }

      dynamic "worker_config" {
        for_each = cluster_config.value.worker_config != null ? [cluster_config.value.worker_config] : []
        content {
          num_instances    = worker_config.value.num_instances
          machine_type     = worker_config.value.machine_type
          min_cpu_platform = worker_config.value.min_cpu_platform
          image_uri        = worker_config.value.image_uri

          dynamic "disk_config" {
            for_each = worker_config.value.disk_config != null ? [worker_config.value.disk_config] : []
            content {
              boot_disk_type    = disk_config.value.boot_disk_type
              boot_disk_size_gb = disk_config.value.boot_disk_size_gb
              num_local_ssds    = disk_config.value.num_local_ssds
            }
          }

          dynamic "accelerators" {
            for_each = worker_config.value.accelerators != null ? worker_config.value.accelerators : []
            content {
              accelerator_type  = accelerators.value.accelerator_type
              accelerator_count = accelerators.value.accelerator_count
            }
          }
        }
      }

      dynamic "preemptible_worker_config" {
        for_each = cluster_config.value.preemptible_worker_config != null ? [cluster_config.value.preemptible_worker_config] : []
        content {
          num_instances  = preemptible_worker_config.value.num_instances
          preemptibility = preemptible_worker_config.value.preemptibility

          dynamic "disk_config" {
            for_each = preemptible_worker_config.value.disk_config != null ? [preemptible_worker_config.value.disk_config] : []
            content {
              boot_disk_type    = disk_config.value.boot_disk_type
              boot_disk_size_gb = disk_config.value.boot_disk_size_gb
              num_local_ssds    = disk_config.value.num_local_ssds
            }
          }
        }
      }

      dynamic "software_config" {
        for_each = cluster_config.value.software_config != null ? [cluster_config.value.software_config] : []
        content {
          image_version       = software_config.value.image_version
          override_properties = software_config.value.override_properties
          optional_components = software_config.value.optional_components
        }
      }

      dynamic "security_config" {
        for_each = cluster_config.value.security_config != null ? [cluster_config.value.security_config] : []
        content {
          dynamic "kerberos_config" {
            for_each = security_config.value.kerberos_config != null ? [security_config.value.kerberos_config] : []
            content {
              cross_realm_trust_admin_server        = kerberos_config.value.cross_realm_trust_admin_server
              cross_realm_trust_kdc                 = kerberos_config.value.cross_realm_trust_kdc
              cross_realm_trust_realm               = kerberos_config.value.cross_realm_trust_realm
              cross_realm_trust_shared_password_uri = kerberos_config.value.cross_realm_trust_shared_password_uri
              enable_kerberos                       = kerberos_config.value.enable_kerberos
              kdc_db_key_uri                        = kerberos_config.value.kdc_db_key_uri
              key_password_uri                      = kerberos_config.value.key_password_uri
              keystore_uri                          = kerberos_config.value.keystore_uri
              keystore_password_uri                 = kerberos_config.value.keystore_password_uri
              kms_key_uri                           = kerberos_config.value.kms_key_uri
              realm                                 = kerberos_config.value.realm
              root_principal_password_uri           = kerberos_config.value.root_principal_password_uri
              tgt_lifetime_hours                    = kerberos_config.value.tgt_lifetime_hours
              truststore_password_uri               = kerberos_config.value.truststore_password_uri
              truststore_uri                        = kerberos_config.value.truststore_uri
            }
          }
        }
      }

      dynamic "autoscaling_config" {
        for_each = cluster_config.value.autoscaling_config != null ? [cluster_config.value.autoscaling_config] : []
        content {
          policy_uri = autoscaling_config.value.policy_uri
        }
      }

      dynamic "initialization_action" {
        for_each = cluster_config.value.initialization_action != null ? [cluster_config.value.initialization_action] : []
        content {
          script      = initialization_action.value.script
          timeout_sec = initialization_action.value.timeout_sec
        }
      }

      dynamic "encryption_config" {
        for_each = cluster_config.value.encryption_config != null ? [cluster_config.value.encryption_config] : []
        content {
          kms_key_name = encryption_config.value.kms_key_name
        }
      }

      dynamic "lifecycle_config" {
        for_each = cluster_config.value.lifecycle_config != null ? [cluster_config.value.lifecycle_config] : []
        content {
          idle_delete_ttl  = lifecycle_config.value.idle_delete_ttl
          auto_delete_time = lifecycle_config.value.auto_delete_time
        }
      }

      dynamic "endpoint_config" {
        for_each = cluster_config.value.endpoint_config != null ? [cluster_config.value.endpoint_config] : []
        content {
          enable_http_port_access = endpoint_config.value.enable_http_port_access
        }
      }

      dynamic "dataproc_metric_config" {
        for_each = cluster_config.value.dataproc_metric_config != null ? [cluster_config.value.dataproc_metric_config] : []
        content {
          dynamic "metrics" {
            for_each = dataproc_metric_config.value.metrics != null ? dataproc_metric_config.value.metrics : []
            content {
              metric_source    = metrics.value.metric_source
              metric_overrides = metrics.value.metric_overrides
            }
          }
        }
      }

      dynamic "metastore_config" {
        for_each = cluster_config.value.metastore_config != null ? [cluster_config.value.metastore_config] : []
        content {
          dataproc_metastore_service = metastore_config.value.dataproc_metastore_service
        }
      }
    }
  }

  # ===================================================
  # Virtual Dataproc on GKE (virtual_cluster_config)
  # ===================================================
  dynamic "virtual_cluster_config" {
    for_each = var.virtual_cluster_config != null ? [var.virtual_cluster_config] : []
    content {
      staging_bucket = virtual_cluster_config.value.staging_bucket

      dynamic "auxiliary_services_config" {
        for_each = virtual_cluster_config.value.auxiliary_services_config != null ? [virtual_cluster_config.value.auxiliary_services_config] : []
        content {
          dynamic "metastore_config" {
            for_each = auxiliary_services_config.value.metastore_config != null ? [auxiliary_services_config.value.metastore_config] : []
            content {
              dataproc_metastore_service = metastore_config.value.dataproc_metastore_service
            }
          }
          dynamic "spark_history_server_config" {
            for_each = auxiliary_services_config.value.spark_history_server_config != null ? [auxiliary_services_config.value.spark_history_server_config] : []
            content {
              dataproc_cluster = spark_history_server_config.value.dataproc_cluster
            }
          }
        }
      }

      dynamic "kubernetes_cluster_config" {
        for_each = virtual_cluster_config.value.kubernetes_cluster_config != null ? [virtual_cluster_config.value.kubernetes_cluster_config] : []
        content {
          kubernetes_namespace = kubernetes_cluster_config.value.kubernetes_namespace

          dynamic "kubernetes_software_config" {
            for_each = kubernetes_cluster_config.value.kubernetes_software_config != null ? [kubernetes_cluster_config.value.kubernetes_software_config] : []
            content {
              component_version = kubernetes_software_config.value.component_version
              properties        = kubernetes_software_config.value.properties
            }
          }

          dynamic "gke_cluster_config" {
            for_each = kubernetes_cluster_config.value.gke_cluster_config != null ? [kubernetes_cluster_config.value.gke_cluster_config] : []
            content {
              gke_cluster_target = gke_cluster_config.value.gke_cluster_target

              dynamic "node_pool_target" {
                for_each = gke_cluster_config.value.node_pool_target != null ? [gke_cluster_config.value.node_pool_target] : []
                content {
                  node_pool = node_pool_target.value.node_pool
                  roles     = node_pool_target.value.roles

                  dynamic "node_pool_config" {
                    for_each = node_pool_target.value.node_pool_config != null ? [node_pool_target.value.node_pool_config] : []
                    content {
                      locations = node_pool_config.value.locations

                      dynamic "autoscaling" {
                        for_each = node_pool_config.value.autoscaling != null ? [node_pool_config.value.autoscaling] : []
                        content {
                          min_node_count = autoscaling.value.min_node_count
                          max_node_count = autoscaling.value.max_node_count
                        }
                      }

                      dynamic "config" {
                        for_each = node_pool_config.value.config != null ? [node_pool_config.value.config] : []
                        content {
                          machine_type     = config.value.machine_type
                          preemptible      = config.value.preemptible
                          local_ssd_count  = config.value.local_ssd_count
                          min_cpu_platform = config.value.min_cpu_platform
                          spot             = config.value.spot
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
