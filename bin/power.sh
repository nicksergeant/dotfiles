/usr/sbin/ioreg -l | awk 'BEGIN{a=0;b=0}
$0 ~ "MaxCapacity" {a=$5;next}
$0 ~ "CurrentCapacity" {b=$5;nextfile}
END{printf("%.0f%%", b/a * 100)}'
