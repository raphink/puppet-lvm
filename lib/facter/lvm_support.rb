# outputs:
# lvm_support: yes/no (based on "vgs" command presence)
# lvm_pvs: [0-9]+
# lvm_vgs: [0-9]+
# lvm_pv_[0-9]+: physical volume name
# lvm_vg_[0-9]+: volume group name

Facter.add("lvm_support") do
  confine :kernel => :linux
  vgdisplay =  Facter::Util::Resolution.exec('which vgs')
  if $?.exitstatus
    vgs = %x[vgs -o name --noheadings 2> /dev/null]
    setcode { 'yes'}
    if vgs.length > 0
      vg_num = 0
      # gives all Volume Groups
      vgs.each do |vg|
        vg.strip!
        Facter.add("lvm_vg_#{vg_num}") { setcode { vg } }
        vg_num += 1
      end
      Facter.add("lvm_vgs") { setcode { vg_num } }
      # gives all Physical Volumes
      pvs = %x[pvs -o name --noheadings 2> /dev/null]
      pv_num = 0
      pvs.each do |pv|
        pv.strip!
        Facter.add("lvm_pv_#{pv_num}") { setcode { pv } }
        pv_num += 1
      end
      Facter.add("lvm_pvs") { setcode { pv_num } }
    else
      Facter.add("lvm_vgs") { setcode { 0 } }
      Facter.add("lvm_pvs") { setcode { %x[pvs -o name --noheadings 2> /dev/null].length } }
    end
  else
    setcode { 'no' }
  end
end
