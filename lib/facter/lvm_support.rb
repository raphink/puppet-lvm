# outputs:
# lvm_support: yes/no (based on "vgs" command presence)
# lvm_pvs: [0-9]+
# lvm_vgs: [0-9]+
# lvm_pv_[0-9]+: physical volume name
# lvm_vg_[0-9]+: volume group name

# Generic LVM support
Facter.add('lvm_support') do
  confine :kernel => :linux

  setcode do
    vgdisplay =  Facter::Util::Resolution.exec('which vgs')
    vgdisplay.nil? ? nil : true
  end
end

# VGs
vg_list = []
Facter.add('lvm_vgs') do
  confine :lvm_support => true
  vgs = Facter::Util::Resolution.exec('vgs -o name --noheadings 2>/dev/null')
  if vgs.nil?
    setcode { 0 }
  else
    vg_list = vgs.split
    setcode { vg_list.length }
  end
end

vg_num = 0
vg_list.each do |vg|
  Facter.add("lvm_vg_#{vg_num}") { setcode { vg } }
  vg_num += 1
end

# PVs
pv_list = []
Facter.add('lvm_pvs') do
  confine :lvm_support => true
  pvs = Facter::Util::Resolution.exec('pvs -o name --noheadings 2>/dev/null')
  if pvs.nil?
    setcode { 0 }
  else
    pv_list = pvs.split
    setcode { pv_list.length }
  end
end

pv_list.each_with_index do |pv, i|
  Facter.add("lvm_pv_#{i}") { setcode { pv } }
end
