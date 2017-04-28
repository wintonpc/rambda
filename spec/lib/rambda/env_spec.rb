require 'rspec'
require 'rambda/env'

module Rambda
  describe Env do
    it 'should work' do
      e = Env.new
      expect { e.look_up(:foo) }.to raise_error Env::NoSuchVar
      e.set(:foo, 42)
      expect(e.look_up(:foo)).to eql 42
      z = Env.new(e)
      z.set(:bar, 99)
      expect(z.look_up(:foo)).to eql 42
      expect(z.look_up(:bar)).to eql 99
      expect { e.look_up(:bar) }.to raise_error Env::NoSuchVar
      z.set(:foo, 44)
      expect(z.look_up(:foo)).to eql 44
    end

    it '#from' do
      e = Env.from(a: 1, b: 2)
      expect(e.look_up(:a)).to eql 1
      expect(e.look_up(:b)).to eql 2
    end
  end
end
