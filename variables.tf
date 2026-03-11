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

variable "project_id" {
  type        = string
  description = "The ID of the project in which the Dataproc Cluster belongs."
}

variable "name" {
  type        = string
  description = "The name of the Dataproc Cluster."
}

variable "labels" {
  type        = map(string)
  description = "The list of labels (key/value pairs) configured on the resource through Terraform and to be applied to instances in the cluster."
  default     = {}
}

variable "region" {
  type        = string
  description = "The region in which the cluster and associated nodes will be created."
}

variable "virtual_cluster_config" {
  description = "Allows you to configure a virtual Dataproc on GKE cluster"
  type = object({
    staging_bucket = optional(string)
    auxiliary_services_config = optional(object({
      metastore_config = optional(object({
        dataproc_metastore_service = string
      }))
      spark_history_server_config = optional(object({
        dataproc_cluster = string
      }))
    }))
    kubernetes_cluster_config = optional(object({
      kubernetes_namespace = optional(string)
      kubernetes_software_config = object({
        component_version = map(string)
        properties        = optional(map(string))
      })
      gke_cluster_config = object({
        gke_cluster_target = optional(string)
        node_pool_target = optional(object({
          node_pool = string
          roles     = list(string)
          node_pool_config = optional(object({
            autoscaling = optional(object({
              min_node_count = optional(number)
              max_node_count = optional(number)
            }))
            config = optional(object({
              machine_type     = optional(string)
              preemptible      = optional(bool)
              local_ssd_count  = optional(number)
              min_cpu_platform = optional(string)
              spot             = optional(bool)
            }))
            locations = optional(list(string))
          }))
        }))
      })
    }))
  })
  default = null
}

variable "cluster_config" {
  description = "Allows you to configure various aspects of the cluster."
  type = object({
    staging_bucket = optional(string)
    temp_bucket    = optional(string)
    gce_cluster_config = optional(object({
      zone                   = optional(string)
      network                = optional(string)
      subnetwork             = optional(string)
      service_account        = optional(string)
      service_account_scopes = optional(list(string))
      tags                   = optional(list(string), [])
      internal_ip_only       = optional(bool)
      metadata               = optional(map(string), {})
      reservation_affinity = optional(object({
        consume_reservation_type = string
        key                      = string
        values                   = list(string)
      }))
      node_group_affinity = optional(object({
        node_group_uri = string
      }))
      shielded_instance_config = optional(object({
        enable_secure_boot          = bool
        enable_vtpm                 = bool
        enable_integrity_monitoring = bool
      }))
      confidential_instance_config = optional(object({
        enable_confidential_compute = bool
      }))
    }))
    master_config = optional(object({
      num_instances    = number
      machine_type     = optional(string)
      min_cpu_platform = optional(string)
      image_uri        = optional(string)
      disk_config = optional(object({
        boot_disk_type    = string
        boot_disk_size_gb = number
        num_local_ssds    = number
      }))
      accelerators = optional(list(object({
        accelerator_type  = string
        accelerator_count = number
      })))
    }))
    worker_config = optional(object({
      num_instances    = number
      machine_type     = optional(string)
      min_cpu_platform = optional(string)
      disk_config = optional(object({
        boot_disk_type    = string
        boot_disk_size_gb = number
        num_local_ssds    = number
      }))
      image_uri = optional(string)
      accelerators = optional(list(object({
        accelerator_type  = string
        accelerator_count = number
      })))
    }))
    preemptible_worker_config = optional(object({
      num_instances  = number
      preemptibility = string
      disk_config = optional(object({
        boot_disk_type    = string
        boot_disk_size_gb = number
        num_local_ssds    = number
      }))
    }))
    software_config = optional(object({
      image_version       = optional(string)
      override_properties = optional(map(string))
      optional_components = optional(list(string))
    }))
    security_config = optional(object({
      kerberos_config = optional(object({
        cross_realm_trust_admin_server        = optional(string)
        cross_realm_trust_kdc                 = optional(string)
        cross_realm_trust_realm               = optional(string)
        cross_realm_trust_shared_password_uri = optional(string)
        enable_kerberos                       = optional(bool)
        kdc_db_key_uri                        = optional(string)
        key_password_uri                      = optional(string)
        keystore_uri                          = optional(string)
        keystore_password_uri                 = optional(string)
        kms_key_uri                           = string
        realm                                 = optional(string)
        root_principal_password_uri           = string
        tgt_lifetime_hours                    = optional(number)
        truststore_password_uri               = optional(string)
        truststore_uri                        = optional(string)
      }))
    }))
    autoscaling_config = optional(object({
      policy_uri = string
    }))
    initialization_action = optional(object({
      script      = string
      timeout_sec = optional(number)
    }))
    encryption_config = optional(object({
      kms_key_name = string
    }))
    lifecycle_config = optional(object({
      idle_delete_ttl  = optional(string)
      auto_delete_time = optional(string)
    }))
    endpoint_config = optional(object({
      enable_http_port_access = bool
    }))
    dataproc_metric_config = optional(object({
      metrics = list(object({
        metric_source    = string
        metric_overrides = optional(list(string))
      }))
    }))
    metastore_config = optional(object({
      dataproc_metastore_service = string
    }))
  })
  default = null
}

variable "graceful_decommission_timeout" {
  type        = string
  description = "Allows graceful decommissioning when you change the number of worker nodes directly through a terraform apply. Does not affect auto scaling decommissioning from an autoscaling policy. Graceful decommissioning allows removing nodes from the cluster without interrupting jobs in progress. Timeout specifies how long to wait for jobs in progress to finish before forcefully removing nodes (and potentially interrupting jobs). Default timeout is 0 (for forceful decommission), and the maximum allowed timeout is 1 day."
  default     = "0"
}
