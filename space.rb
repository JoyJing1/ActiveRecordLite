class SarahBeachCat
  def fire_whisker_lasers
    puts "pew pew pew go the whisker lasers"
  end

  def fire_claw_lasers
    puts "bang bang go the claw lasers"
  end

  def tail_engine(percent)
    puts "setting tail engine to #{percent}%"
    @tail = percent
  end

  def fur_engine(percent)
    puts "setting fur engine to #{percent}%"
    @fur = percent
  end

  def store_in_fannypack_bay(stuff)
    cargo['fannypack'] = stuff
  end

  def store_in_other_bay(stuff)
    hash['other'] = stuff
  end

  def cargo
    @cargo ||= {}
  end


  def unload_cargo
    loot = cargo.values
    @cargo = {}
    loot
  end
end

class SpaceBase
  def self.install_lasers(names)
    names.each do |name, sound|
      self
      define_method("fire_#{name}_lasers") do
        self
        puts "#{sound} #{sound} go the #{name} lasers"
      end
    end
  end

  def self.mount_engines(*names)
    names.each do |name|
      define_method("set_#{name}_engine") do |percent|
        puts "setting #{name} engine to #{percent}%"
        instance_variable_set("@#{name}", percent)
      end
    end
  end

  def self.attach_cargo_bays(*names)
    names.each do |name|
      define_method("store_in_#{name}_bay") do |stuff|
        cargo[name] = stuff
      end
    end

    define_method("unload_cargo") do
      loot = cargo.values
      @cargo = {}
      loot
    end

    define_method("cargo") do
      @cargo ||= {}
    end
  end
end

class Sarah2 < SpaceBase
  install_lasers meow: :mew, claw: :scratch
  mount_engines :fur, :purr
  attach_cargo_bays :fannypack, :satchel
end

s = Sarah2.new
s.fire_meow_lasers
