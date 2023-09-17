Br load("Shelly_PlugUS.autoconf#migrate_shelly.be")
Template {"NAME":"Shelly Plug US","GPIO":[52,0,57,0,21,134,0,0,131,17,132,157,0],"FLAG":0,"BASE":45}
Module 0
rule1 on power1#state do backlog ledpower1 %value%; ledpower2 %value% endon on power1#boot do backlog ledpower1 %value%; ledpower2 %value% endon

