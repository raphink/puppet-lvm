#!/usr/bin/env rspec

require 'spec_helper'

describe "lvm_support fact" do
  describe 'on non-Linux OS' do
    it 'should not exist' do
      Facter.fact(:kernel).stubs(:value).returns('SunOS')
      Facter.fact(:lvm_support).value.should == nil
    end
  end
  
  describe 'on Linux' do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns('Linux')
      Facter.collection.loader.load(:filesystems)
    end
    
    after :each do
      Facter.clear
    end
    
    it 'should exist' do
      Facter.fact(:lvm_support).value.should_not == nil
    end
    
    it 'has no vgs' do
      Facter::Util::Resolution.stubs(:exec).with('which vgdisplay 2>&1').returns(nil)

      Facter.value(:lvm_support).should == 'no'
    end
    
    it 'has vgs but no volume group' do
      Facter::Util::Resolution.stubs(:exec).with('which vgdisplay 2>&1').returns('/sbin/vgs')
      Facter::Util::Resolution.stubs(:exec).with('vgs -o name --noheadings 2> /dev/null').returns(nil)

      Facter.value(:lvm_support).should == 'yes'
      Facter.value(:lvm_vgs).should == 0
    end
    
    it 'has vgdisplay, one physical volume and two volume group' do
      Facter::Util::Resolution.stubs(:exec).with('which vgs 2>&1').returns('/sbin/vgdisplay')
      Facter::Util::Resolution.stubs(:exec).with('vgs -o name --noheadings 2> /dev/null').returns("vg0\nvg1")
      Facter::Util::Resolution.stubs(:exec).with('pvs -o name --noheadings 2> /dev/null').returns("pv0")

      Facter.value(:lvm_support).should == 'yes'
      Facter.value(:lvm_vgs).should == 2
      Facter.value(:lvm_vg_0).should == 'vg0'
      Facter.value(:lvm_vg_1).should == 'vg1'
      Facter.value(:lvm_pvs).should == 1
      Facter.value(:lvm_pv_0).should == 'pv0'
    end
  end
end
