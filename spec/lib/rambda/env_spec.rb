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

    it '#set sets at the right level' do
      e1 = Env.from(a: 1)
      e2 = Env.new(e1)
      e3 = Env.new(e1)
      e2.set(:a, 9)
      expect(e1.look_up(:a)).to eql 9
      expect(e2.look_up(:a)).to eql 9
      expect(e3.look_up(:a)).to eql 9
    end
  end
end
