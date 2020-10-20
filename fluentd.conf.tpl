<source>
  @type tail
  ## log file with absolute path
  path /var/log/elasticsearch/${cluster_name}.log
  ##take the file reading position so that it can continue from same position if restarted
  pos_file /var/lib/google-fluentd/pos/${cluster_name}.pos
  tag elasticsearch_log
  open_on_every_update false
  emit_unmatched_lines false
  read_from_head false
  <parse>
    @type regexp
    expression /^\[(?<timestamp>[^\]]*)\]\[(?<level>[^\]]*)\]\[(?<thread>[^\]]*)\] \[(?<host>[^\]]*)\] +(?<message>[^ ].*$)/
  </parse>
</source>
