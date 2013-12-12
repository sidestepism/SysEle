# -*- encoding: utf-8 -*-

include Math

class Reg
    attr_accessor :i, :d
    def initialize(i)
        @i = i
        @d = 32 * (i & 0x01) + 16 * (i & 0x02)/0x02 + 8 * (i & 0x04)/0x04 + 4 * (i & 0x08)/0x08 + 2 * (i & 0x10)/0x10 + 1 * (i & 0x20)/0x20
    end
    def butterflyWith(other, n)
        # n: W_n
        d0 = self.d
        d1 = other.d
        def wr(i)
            return (cos(i) * 2**24).floor
        end
        def wi(i)
            return (sin(i) * 2**24).floor
        end
        return ["datar[xk(#{d0})] <= datar[#{d0}] + (datar[#{d1}] * #{wr(n)} - datai[#{d1}] * #{wi(n)}) <<< 24;",
         "datai[xk(#{d0})] <= datai[#{d0}] + (datar[#{d1}] * #{wi(n)} + datai[#{d1}] * #{wr(n)}) <<< 24;",
         "datar[xk(#{d0})] <= datar[#{d0}] - (datar[#{d1}] * #{wr(n)} + datai[#{d1}] * #{wi(n)}) <<< 24;",
         "datai[xk(#{d0})] <= datai[#{d0}] - (datar[#{d1}] * #{wi(n)} - datai[#{d1}] * #{wr(n)}) <<< 24;"]
    end
end


class Car
  def initialize(carname)
    @name = carname
  end
  
  def dispName
    print(@name, "¥n")
  end
end

regs = [];
butterflies = [];

64.times do |i|
    regs [i] = Reg.new(i)
end

6.times do |k|
    # k段目
    32.times do |i|
        # i個目のバタフライ
        a = i/(2**k)*(2**(k+1)) + i%(2**k)
        b = i/(2**k)*(2**(k+1)) + i%(2**k) + 2**k
        # 文を追加
        butterflies += regs[a].butterflyWith(regs [b], (i*32/2**k)%64);
    end
end

state = 2;
while !butterflies.empty?
    print "#{state}: begin\n"
    butterflies[0, 6].map { |a|
        print "    " + a + "\n"
    }
    butterflies[0, 6] = [];
    state += 1
    print "    state <= #{state}\n"
    print "end\n"
    
end

