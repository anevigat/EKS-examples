metrics:
  wal_directory: /var/lib/agent/wal
  global:
    scrape_interval: 60s
    external_labels:
      cluster: ${CLUSTER}
  configs:
  - name: integrations
    remote_write:
    - url: ${GRAFANA_HOST}
      basic_auth:
        username: ${GRAFANA_USER}
        password: ${GRAFANA_PASSWORD}
    scrape_configs:
    - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      job_name: integrations/kubernetes/cadvisor
      kubernetes_sd_configs:
          - role: node
      metric_relabel_configs:
          - source_labels: [__name__]
            regex: kubelet_running_containers|go_goroutines|kubelet_runtime_operations_errors_total|cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits|namespace_memory:kube_pod_container_resource_limits:sum|kubelet_volume_stats_inodes_used|kubelet_certificate_manager_server_ttl_seconds|namespace_workload_pod:kube_pod_owner:relabel|kubelet_node_config_error|kube_daemonset_status_number_misscheduled|kube_pod_container_resource_requests|namespace_cpu:kube_pod_container_resource_limits:sum|container_memory_working_set_bytes|container_fs_reads_bytes_total|kube_node_status_condition|namespace_cpu:kube_pod_container_resource_requests:sum|kubelet_server_expiration_renew_errors|container_fs_writes_total|kube_horizontalpodautoscaler_status_desired_replicas|node_filesystem_avail_bytes|kube_pod_status_reason|node_filesystem_size_bytes|kube_deployment_spec_replicas|kube_statefulset_metadata_generation|namespace_workload_pod|storage_operation_duration_seconds_count|kubelet_certificate_manager_client_expiration_renew_errors|kube_pod_container_resource_limits|kube_statefulset_status_replicas_updated|node_namespace_pod_container:container_memory_rss|kube_statefulset_status_observed_generation|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|kubelet_pleg_relist_interval_seconds_bucket|kube_job_status_start_time|kube_deployment_status_observed_generation|kubelet_pod_worker_duration_seconds_bucket|container_memory_cache|kube_resourcequota|kube_horizontalpodautoscaler_spec_min_replicas|namespace_memory:kube_pod_container_resource_requests:sum|kube_persistentvolumeclaim_resource_requests_storage_bytes|kube_daemonset_status_number_available|kube_job_failed|storage_operation_errors_total|cluster:namespace:pod_memory:active:kube_pod_container_resource_limits|container_fs_writes_bytes_total|kube_statefulset_replicas|kube_replicaset_owner|container_network_receive_bytes_total|volume_manager_total_volumes|kube_horizontalpodautoscaler_spec_max_replicas|kube_daemonset_status_desired_number_scheduled|kube_pod_container_status_waiting_reason|process_cpu_seconds_total|kube_node_status_allocatable|kube_deployment_status_replicas_available|kube_daemonset_status_updated_number_scheduled|container_network_receive_packets_total|container_memory_rss|container_cpu_usage_seconds_total|kube_namespace_status_phase|cluster:namespace:pod_memory:active:kube_pod_container_resource_requests|kubelet_volume_stats_available_bytes|kube_deployment_status_replicas_updated|kubelet_running_container_count|kube_node_info|container_network_transmit_packets_dropped_total|kubelet_certificate_manager_client_ttl_seconds|kube_pod_owner|kubelet_volume_stats_inodes|kubelet_runtime_operations_total|container_cpu_cfs_throttled_periods_total|kubelet_cgroup_manager_duration_seconds_bucket|kubelet_running_pod_count|container_network_transmit_packets_total|kubelet_node_name|kube_daemonset_status_current_number_scheduled|kube_statefulset_status_replicas_ready|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|kubelet_volume_stats_capacity_bytes|kube_horizontalpodautoscaler_status_current_replicas|node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile|kube_node_spec_taint|kubelet_pleg_relist_duration_seconds_bucket|kube_pod_status_phase|container_cpu_cfs_periods_total|kube_deployment_metadata_generation|node_namespace_pod_container:container_memory_cache|kube_statefulset_status_current_revision|kubelet_pleg_relist_duration_seconds_count|container_fs_reads_total|kube_statefulset_status_update_revision|container_network_receive_packets_dropped_total|kube_pod_info|kubelet_running_pods|process_resident_memory_bytes|kubelet_pod_worker_duration_seconds_count|kubelet_pod_start_duration_seconds_count|kubelet_cgroup_manager_duration_seconds_count|kube_node_status_capacity|container_network_transmit_bytes_total|rest_client_requests_total|kubernetes_build_info|machine_memory_bytes|kube_statefulset_status_replicas|container_memory_swap|kube_job_status_active|kubelet_pod_start_duration_seconds_bucket|node_namespace_pod_container:container_memory_working_set_bytes|node_namespace_pod_container:container_memory_swap|kube_namespace_status_phase|container_cpu_usage_seconds_total|kube_pod_status_phase|kube_pod_start_time|kube_pod_container_status_restarts_total|kube_pod_container_info|kube_pod_container_status_waiting_reason|kube_daemonset.*|kube_replicaset.*|kube_statefulset.*|kube_job.*|kube_node.*|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|namespace_cpu:kube_pod_container_resource_requests:sum|node_cpu.*|node_memory.*|node_filesystem.*|node_network_transmit_bytes_total
            action: keep
      relabel_configs:
          - replacement: kubernetes.default.svc.cluster.local:443
            target_label: __address__
          - regex: (.+)
            replacement: /api/v1/nodes/$${1}/proxy/metrics/cadvisor
            source_labels:
              - __meta_kubernetes_node_name
            target_label: __metrics_path__
      scheme: https
      tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: false
          server_name: kubernetes
    - job_name: integrations/kubernetes/kubelet
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      kubernetes_sd_configs:
          - role: node
      metric_relabel_configs:
          - source_labels: [__name__]
            regex: kubelet_running_containers|go_goroutines|kubelet_runtime_operations_errors_total|cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits|namespace_memory:kube_pod_container_resource_limits:sum|kubelet_volume_stats_inodes_used|kubelet_certificate_manager_server_ttl_seconds|namespace_workload_pod:kube_pod_owner:relabel|kubelet_node_config_error|kube_daemonset_status_number_misscheduled|kube_pod_container_resource_requests|namespace_cpu:kube_pod_container_resource_limits:sum|container_memory_working_set_bytes|container_fs_reads_bytes_total|kube_node_status_condition|namespace_cpu:kube_pod_container_resource_requests:sum|kubelet_server_expiration_renew_errors|container_fs_writes_total|kube_horizontalpodautoscaler_status_desired_replicas|node_filesystem_avail_bytes|kube_pod_status_reason|node_filesystem_size_bytes|kube_deployment_spec_replicas|kube_statefulset_metadata_generation|namespace_workload_pod|storage_operation_duration_seconds_count|kubelet_certificate_manager_client_expiration_renew_errors|kube_pod_container_resource_limits|kube_statefulset_status_replicas_updated|node_namespace_pod_container:container_memory_rss|kube_statefulset_status_observed_generation|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|kubelet_pleg_relist_interval_seconds_bucket|kube_job_status_start_time|kube_deployment_status_observed_generation|kubelet_pod_worker_duration_seconds_bucket|container_memory_cache|kube_resourcequota|kube_horizontalpodautoscaler_spec_min_replicas|namespace_memory:kube_pod_container_resource_requests:sum|kube_persistentvolumeclaim_resource_requests_storage_bytes|kube_daemonset_status_number_available|kube_job_failed|storage_operation_errors_total|cluster:namespace:pod_memory:active:kube_pod_container_resource_limits|container_fs_writes_bytes_total|kube_statefulset_replicas|kube_replicaset_owner|container_network_receive_bytes_total|volume_manager_total_volumes|kube_horizontalpodautoscaler_spec_max_replicas|kube_daemonset_status_desired_number_scheduled|kube_pod_container_status_waiting_reason|process_cpu_seconds_total|kube_node_status_allocatable|kube_deployment_status_replicas_available|kube_daemonset_status_updated_number_scheduled|container_network_receive_packets_total|container_memory_rss|container_cpu_usage_seconds_total|kube_namespace_status_phase|cluster:namespace:pod_memory:active:kube_pod_container_resource_requests|kubelet_volume_stats_available_bytes|kube_deployment_status_replicas_updated|kubelet_running_container_count|kube_node_info|container_network_transmit_packets_dropped_total|kubelet_certificate_manager_client_ttl_seconds|kube_pod_owner|kubelet_volume_stats_inodes|kubelet_runtime_operations_total|container_cpu_cfs_throttled_periods_total|kubelet_cgroup_manager_duration_seconds_bucket|kubelet_running_pod_count|container_network_transmit_packets_total|kubelet_node_name|kube_daemonset_status_current_number_scheduled|kube_statefulset_status_replicas_ready|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|kubelet_volume_stats_capacity_bytes|kube_horizontalpodautoscaler_status_current_replicas|node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile|kube_node_spec_taint|kubelet_pleg_relist_duration_seconds_bucket|kube_pod_status_phase|container_cpu_cfs_periods_total|kube_deployment_metadata_generation|node_namespace_pod_container:container_memory_cache|kube_statefulset_status_current_revision|kubelet_pleg_relist_duration_seconds_count|container_fs_reads_total|kube_statefulset_status_update_revision|container_network_receive_packets_dropped_total|kube_pod_info|kubelet_running_pods|process_resident_memory_bytes|kubelet_pod_worker_duration_seconds_count|kubelet_pod_start_duration_seconds_count|kubelet_cgroup_manager_duration_seconds_count|kube_node_status_capacity|container_network_transmit_bytes_total|rest_client_requests_total|kubernetes_build_info|machine_memory_bytes|kube_statefulset_status_replicas|container_memory_swap|kube_job_status_active|kubelet_pod_start_duration_seconds_bucket|node_namespace_pod_container:container_memory_working_set_bytes|node_namespace_pod_container:container_memory_swap|kube_namespace_status_phase|container_cpu_usage_seconds_total|kube_pod_status_phase|kube_pod_start_time|kube_pod_container_status_restarts_total|kube_pod_container_info|kube_pod_container_status_waiting_reason|kube_daemonset.*|kube_replicaset.*|kube_statefulset.*|kube_job.*|kube_node.*|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|namespace_cpu:kube_pod_container_resource_requests:sum|node_cpu.*|node_memory.*|node_filesystem.*|node_network_transmit_bytes_total
            action: keep
      relabel_configs:
          - replacement: kubernetes.default.svc.cluster.local:443
            target_label: __address__
          - regex: (.+)
            replacement: /api/v1/nodes/$${1}/proxy/metrics
            source_labels:
              - __meta_kubernetes_node_name
            target_label: __metrics_path__
      scheme: https
      tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: false
          server_name: kubernetes
    - job_name: integrations/kubernetes/kube-state-metrics
      kubernetes_sd_configs:
          - role: pod
      metric_relabel_configs:
          - source_labels: [__name__]
            regex: kubelet_running_containers|go_goroutines|kubelet_runtime_operations_errors_total|cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits|namespace_memory:kube_pod_container_resource_limits:sum|kubelet_volume_stats_inodes_used|kubelet_certificate_manager_server_ttl_seconds|namespace_workload_pod:kube_pod_owner:relabel|kubelet_node_config_error|kube_daemonset_status_number_misscheduled|kube_pod_container_resource_requests|namespace_cpu:kube_pod_container_resource_limits:sum|container_memory_working_set_bytes|container_fs_reads_bytes_total|kube_node_status_condition|namespace_cpu:kube_pod_container_resource_requests:sum|kubelet_server_expiration_renew_errors|container_fs_writes_total|kube_horizontalpodautoscaler_status_desired_replicas|node_filesystem_avail_bytes|kube_pod_status_reason|node_filesystem_size_bytes|kube_deployment_spec_replicas|kube_statefulset_metadata_generation|namespace_workload_pod|storage_operation_duration_seconds_count|kubelet_certificate_manager_client_expiration_renew_errors|kube_pod_container_resource_limits|kube_statefulset_status_replicas_updated|node_namespace_pod_container:container_memory_rss|kube_statefulset_status_observed_generation|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|kubelet_pleg_relist_interval_seconds_bucket|kube_job_status_start_time|kube_deployment_status_observed_generation|kubelet_pod_worker_duration_seconds_bucket|container_memory_cache|kube_resourcequota|kube_horizontalpodautoscaler_spec_min_replicas|namespace_memory:kube_pod_container_resource_requests:sum|kube_persistentvolumeclaim_resource_requests_storage_bytes|kube_daemonset_status_number_available|kube_job_failed|storage_operation_errors_total|cluster:namespace:pod_memory:active:kube_pod_container_resource_limits|container_fs_writes_bytes_total|kube_statefulset_replicas|kube_replicaset_owner|container_network_receive_bytes_total|volume_manager_total_volumes|kube_horizontalpodautoscaler_spec_max_replicas|kube_daemonset_status_desired_number_scheduled|kube_pod_container_status_waiting_reason|process_cpu_seconds_total|kube_node_status_allocatable|kube_deployment_status_replicas_available|kube_daemonset_status_updated_number_scheduled|container_network_receive_packets_total|container_memory_rss|container_cpu_usage_seconds_total|kube_namespace_status_phase|cluster:namespace:pod_memory:active:kube_pod_container_resource_requests|kubelet_volume_stats_available_bytes|kube_deployment_status_replicas_updated|kubelet_running_container_count|kube_node_info|container_network_transmit_packets_dropped_total|kubelet_certificate_manager_client_ttl_seconds|kube_pod_owner|kubelet_volume_stats_inodes|kubelet_runtime_operations_total|container_cpu_cfs_throttled_periods_total|kubelet_cgroup_manager_duration_seconds_bucket|kubelet_running_pod_count|container_network_transmit_packets_total|kubelet_node_name|kube_daemonset_status_current_number_scheduled|kube_statefulset_status_replicas_ready|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|kubelet_volume_stats_capacity_bytes|kube_horizontalpodautoscaler_status_current_replicas|node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile|kube_node_spec_taint|kubelet_pleg_relist_duration_seconds_bucket|kube_pod_status_phase|container_cpu_cfs_periods_total|kube_deployment_metadata_generation|node_namespace_pod_container:container_memory_cache|kube_statefulset_status_current_revision|kubelet_pleg_relist_duration_seconds_count|container_fs_reads_total|kube_statefulset_status_update_revision|container_network_receive_packets_dropped_total|kube_pod_info|kubelet_running_pods|process_resident_memory_bytes|kubelet_pod_worker_duration_seconds_count|kubelet_pod_start_duration_seconds_count|kubelet_cgroup_manager_duration_seconds_count|kube_node_status_capacity|container_network_transmit_bytes_total|rest_client_requests_total|kubernetes_build_info|machine_memory_bytes|kube_statefulset_status_replicas|container_memory_swap|kube_job_status_active|kubelet_pod_start_duration_seconds_bucket|node_namespace_pod_container:container_memory_working_set_bytes|node_namespace_pod_container:container_memory_swap|kube_namespace_status_phase|container_cpu_usage_seconds_total|kube_pod_status_phase|kube_pod_start_time|kube_pod_container_status_restarts_total|kube_pod_container_info|kube_pod_container_status_waiting_reason|kube_daemonset.*|kube_replicaset.*|kube_statefulset.*|kube_job.*|kube_node.*|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|namespace_cpu:kube_pod_container_resource_requests:sum|node_cpu.*|node_memory.*|node_filesystem.*|node_network_transmit_bytes_total
            action: keep
      relabel_configs:
          - action: keep
            regex: kube-state-metrics
            source_labels:
              - __meta_kubernetes_pod_label_app_kubernetes_io_name
    - job_name: integrations/node_exporter
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      kubernetes_sd_configs:
          - namespaces:
              names:
                  - default
            role: pod
      metric_relabel_configs:
          - source_labels: [__name__]
            regex: kubelet_running_containers|go_goroutines|kubelet_runtime_operations_errors_total|cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits|namespace_memory:kube_pod_container_resource_limits:sum|kubelet_volume_stats_inodes_used|kubelet_certificate_manager_server_ttl_seconds|namespace_workload_pod:kube_pod_owner:relabel|kubelet_node_config_error|kube_daemonset_status_number_misscheduled|kube_pod_container_resource_requests|namespace_cpu:kube_pod_container_resource_limits:sum|container_memory_working_set_bytes|container_fs_reads_bytes_total|kube_node_status_condition|namespace_cpu:kube_pod_container_resource_requests:sum|kubelet_server_expiration_renew_errors|container_fs_writes_total|kube_horizontalpodautoscaler_status_desired_replicas|node_filesystem_avail_bytes|kube_pod_status_reason|node_filesystem_size_bytes|kube_deployment_spec_replicas|kube_statefulset_metadata_generation|namespace_workload_pod|storage_operation_duration_seconds_count|kubelet_certificate_manager_client_expiration_renew_errors|kube_pod_container_resource_limits|kube_statefulset_status_replicas_updated|node_namespace_pod_container:container_memory_rss|kube_statefulset_status_observed_generation|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|kubelet_pleg_relist_interval_seconds_bucket|kube_job_status_start_time|kube_deployment_status_observed_generation|kubelet_pod_worker_duration_seconds_bucket|container_memory_cache|kube_resourcequota|kube_horizontalpodautoscaler_spec_min_replicas|namespace_memory:kube_pod_container_resource_requests:sum|kube_persistentvolumeclaim_resource_requests_storage_bytes|kube_daemonset_status_number_available|kube_job_failed|storage_operation_errors_total|cluster:namespace:pod_memory:active:kube_pod_container_resource_limits|container_fs_writes_bytes_total|kube_statefulset_replicas|kube_replicaset_owner|container_network_receive_bytes_total|volume_manager_total_volumes|kube_horizontalpodautoscaler_spec_max_replicas|kube_daemonset_status_desired_number_scheduled|kube_pod_container_status_waiting_reason|process_cpu_seconds_total|kube_node_status_allocatable|kube_deployment_status_replicas_available|kube_daemonset_status_updated_number_scheduled|container_network_receive_packets_total|container_memory_rss|container_cpu_usage_seconds_total|kube_namespace_status_phase|cluster:namespace:pod_memory:active:kube_pod_container_resource_requests|kubelet_volume_stats_available_bytes|kube_deployment_status_replicas_updated|kubelet_running_container_count|kube_node_info|container_network_transmit_packets_dropped_total|kubelet_certificate_manager_client_ttl_seconds|kube_pod_owner|kubelet_volume_stats_inodes|kubelet_runtime_operations_total|container_cpu_cfs_throttled_periods_total|kubelet_cgroup_manager_duration_seconds_bucket|kubelet_running_pod_count|container_network_transmit_packets_total|kubelet_node_name|kube_daemonset_status_current_number_scheduled|kube_statefulset_status_replicas_ready|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|kubelet_volume_stats_capacity_bytes|kube_horizontalpodautoscaler_status_current_replicas|node_quantile:kubelet_pleg_relist_duration_seconds:histogram_quantile|kube_node_spec_taint|kubelet_pleg_relist_duration_seconds_bucket|kube_pod_status_phase|container_cpu_cfs_periods_total|kube_deployment_metadata_generation|node_namespace_pod_container:container_memory_cache|kube_statefulset_status_current_revision|kubelet_pleg_relist_duration_seconds_count|container_fs_reads_total|kube_statefulset_status_update_revision|container_network_receive_packets_dropped_total|kube_pod_info|kubelet_running_pods|process_resident_memory_bytes|kubelet_pod_worker_duration_seconds_count|kubelet_pod_start_duration_seconds_count|kubelet_cgroup_manager_duration_seconds_count|kube_node_status_capacity|container_network_transmit_bytes_total|rest_client_requests_total|kubernetes_build_info|machine_memory_bytes|kube_statefulset_status_replicas|container_memory_swap|kube_job_status_active|kubelet_pod_start_duration_seconds_bucket|node_namespace_pod_container:container_memory_working_set_bytes|node_namespace_pod_container:container_memory_swap|kube_namespace_status_phase|container_cpu_usage_seconds_total|kube_pod_status_phase|kube_pod_start_time|kube_pod_container_status_restarts_total|kube_pod_container_info|kube_pod_container_status_waiting_reason|kube_daemonset.*|kube_replicaset.*|kube_statefulset.*|kube_job.*|kube_node.*|node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate|cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests|namespace_cpu:kube_pod_container_resource_requests:sum|node_cpu.*|node_memory.*|node_filesystem.*|node_network_transmit_bytes_total
            action: keep
      relabel_configs:
          - action: keep
            regex: prometheus-node-exporter.*
            source_labels:
              - __meta_kubernetes_pod_label_app_kubernetes_io_name
          - action: replace
            source_labels:
              - __meta_kubernetes_pod_node_name
            target_label: instance
          - action: replace
            source_labels:
              - __meta_kubernetes_namespace
            target_label: namespace
      tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: false
    - job_name: integrations/grafana-mimir/kube-state-metrics
      kubernetes_sd_configs:
        - role: pod
      relabel_configs:
        - source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_name]
          action: keep
          regex: kube-state-metrics
        - action: replace # Replace the cluster label if it isn't present already
          regex: ""
          replacement: k8s-cluster
          separator: ""
          source_labels:
            - cluster
          target_label: cluster
      metric_relabel_configs:
        - regex: '(.*-mimir-)?alertmanager.*|(.*-mimir-)?alertmanager-im.*|(.*-mimir-)?(query-scheduler|ruler-query-scheduler|ruler|store-gateway|compactor|alertmanager|overrides-exporter|mimir-backend).*|(.*-mimir-)?compactor.*|(.*-mimir-)?distributor.*|(.*-mimir-)?(gateway|cortex-gw|cortex-gw-internal).*|(.*-mimir-)?ingester.*|(.*-mimir-)?mimir-backend.*|(.*-mimir-)?mimir-read.*|(.*-mimir-)?mimir-write.*|(.*-mimir-)?overrides-exporter.*|(.*-mimir-)?querier.*|(.*-mimir-)?query-frontend.*|(.*-mimir-)?query-scheduler.*|(.*-mimir-)?(query-frontend|querier|ruler-query-frontend|ruler-querier|mimir-read).*|(.*-mimir-)?ruler.*|(.*-mimir-)?ruler-querier.*|(.*-mimir-)?ruler-query-frontend.*|(.*-mimir-)?ruler-query-scheduler.*|(.*-mimir-)?store-gateway.*|(.*-mimir-)?(distributor|ingester|mimir-write).*'
          action: keep
          separator: ''
          source_labels: [ deployment, statefulset, pod ]
    - job_name: integrations/grafana-mimir/kubelet
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      kubernetes_sd_configs:
        - role: node
      relabel_configs:
        - replacement: kubernetes.default.svc.cluster.local:443
          target_label: __address__
        - regex: (.+)
          replacement: /api/v1/nodes/$${1}/proxy/metrics
          source_labels:
            - __meta_kubernetes_node_name
          target_label: __metrics_path__
        - action: replace # Replace the cluster label if it isn't present already
          regex: ""
          replacement: k8s-cluster
          separator: ""
          source_labels:
            - cluster
          target_label: cluster
      metric_relabel_configs:
        - regex: kubelet_volume_stats.*
          action: keep
          source_labels: [ __name__ ]
      scheme: https
      tls_config:
          ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          insecure_skip_verify: false
          server_name: kubernetes
    - job_name: integrations/grafana-mimir/cadvisor
      bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      kubernetes_sd_configs:
        - role: node
      relabel_configs:
        - replacement: kubernetes.default.svc.cluster.local:443
          target_label: __address__
        - regex: (.+)
          replacement: /api/v1/nodes/$${1}/proxy/metrics/cadvisor
          source_labels:
            - __meta_kubernetes_node_name
          target_label: __metrics_path__
        - action: replace # Replace the cluster label if it isn't present already
          regex: ""
          replacement: k8s-cluster
          separator: ""
          source_labels:
            - cluster
          target_label: cluster
      metric_relabel_configs:
        - regex: '(.*-mimir-)?alertmanager.*|(.*-mimir-)?alertmanager-im.*|(.*-mimir-)?(query-scheduler|ruler-query-scheduler|ruler|store-gateway|compactor|alertmanager|overrides-exporter|mimir-backend).*|(.*-mimir-)?compactor.*|(.*-mimir-)?distributor.*|(.*-mimir-)?(gateway|cortex-gw|cortex-gw-internal).*|(.*-mimir-)?ingester.*|(.*-mimir-)?mimir-backend.*|(.*-mimir-)?mimir-read.*|(.*-mimir-)?mimir-write.*|(.*-mimir-)?overrides-exporter.*|(.*-mimir-)?querier.*|(.*-mimir-)?query-frontend.*|(.*-mimir-)?query-scheduler.*|(.*-mimir-)?(query-frontend|querier|ruler-query-frontend|ruler-querier|mimir-read).*|(.*-mimir-)?ruler.*|(.*-mimir-)?ruler-querier.*|(.*-mimir-)?ruler-query-frontend.*|(.*-mimir-)?ruler-query-scheduler.*|(.*-mimir-)?store-gateway.*|(.*-mimir-)?(distributor|ingester|mimir-write).*'
          action: keep
          source_labels: [ pod ]
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        insecure_skip_verify: false
        server_name: kubernetes
    - job_name: integrations/grafana-mimir/metrics
      kubernetes_sd_configs:
        - role: pod
      relabel_configs:
        # The mimir-distributed Helm chart names all ports which expose a /metrics endpoint with the 'metrics' suffix, so we keep only those targets.
        - regex: .*metrics
          action: keep
          source_labels:
            - __meta_kubernetes_pod_container_port_name
        # Keep only targets which are a part of the expected Helm chart
        - action: keep
          regex: mimir-distributed-.*
          source_labels:
            - __meta_kubernetes_pod_label_helm_sh_chart
        # The following labels are required to ensure the pre-built dashboards are fully functional later.
        - action: replace  # Replace the cluster label if it isn't present already
          regex: ""
          replacement: k8s-cluster
          separator: ""
          source_labels:
            - cluster
          target_label: cluster
        - action: replace
          source_labels:
            - __meta_kubernetes_namespace
          target_label: namespace
        - action: replace
          source_labels:
            - __meta_kubernetes_pod_name
          target_label: pod
        - action: replace
          source_labels:
            - __meta_kubernetes_pod_container_name
          target_label: container
        - action: replace
          separator: ""
          source_labels:
            - __meta_kubernetes_pod_label_name
            - __meta_kubernetes_pod_label_app_kubernetes_io_component
          target_label: __tmp_component_name
        - action: replace
          separator: /
          source_labels: [ __meta_kubernetes_namespace, __tmp_component_name ]
          target_label: job
        - action: replace
          source_labels:
            - __meta_kubernetes_pod_node_name
          target_label: instance
    - job_name: integrations/kubernetes/opencost
      kubernetes_sd_configs:
        - role: pod
      relabel_configs:
        - action: keep
          regex: opencost-*
          source_labels:
            - __meta_kubernetes_pod_label_app_kubernetes_io_name
    - job_name: redis_exporter
      static_configs:
        - targets: ['nexus-cache-main-redis-metrics.nexus-cache-main.svc.cluster.local:9121']

integrations:
  eventhandler:
    cache_path: /var/lib/agent/eventhandler.cache
    logs_instance: integrations
logs:
  configs:
  - name: integrations
    clients:
    - url: ${GRAFANA_LOKI_HOST}
      basic_auth:
        username: ${GRAFANA_LOKI_USER}
        password: ${GRAFANA_PASSWORD}
      external_labels:
        cluster: ${CLUSTER}
        job: integrations/kubernetes/eventhandler
    positions:
      filename: /tmp/positions.yaml
    target_config:
      sync_period: 10s