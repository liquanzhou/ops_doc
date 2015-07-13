/root/task_auto.sh:
  file.managed:
    - source: salt://gearmand/task_auto.sh
    - mode: 755
sh /root/task_auto.sh:
  cmd.run:
    - require:
      - file: /root/task_auto.sh