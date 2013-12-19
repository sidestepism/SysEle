# -*- encoding: utf-8 -*-

include Math

64.times do |i|
    print "wire [width-1:0] datawr#{i}; assign datawr#{i} = datar[#{i}]; \n"
    print "wire [width-1:0] datawi#{i}; assign datawi#{i} = datai[#{i}]; \n"
end

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
            s = cos(i.to_f/32*PI)
            t = (s * (2**11)).round
            return t;
        end

        def wi(i)
            s = -sin(i.to_f/32*PI)
            t = (s * (2**11)).round
            return t;
        end
        # print "#{wr(n)}, #{wi(n)}\n"

        return [["datar[#{d0}]", "datai[#{d0}]", "datar[#{d1}]", "datai[#{d1}]", "#{wr(n)}", "#{wi(n)}"]]
         #    "datar[#{d0}] <= datar[#{d0}] + (datar[#{d1}] * #{wr(n)} - datai[#{d1}] * #{wi(n)}) <<< 24;",
         # "datai[#{d0}] <= datai[#{d0}] + (datar[#{d1}] * #{wi(n)} + datai[#{d1}] * #{wr(n)}) <<< 24;",
         # "datar[#{d0}] <= datar[#{d0}] - (datar[#{d1}] * #{wr(n)} + datai[#{d1}] * #{wi(n)}) <<< 24;",
         # "datai[#{d0}] <= datai[#{d0}] - (datar[#{d1}] * #{wi(n)} - datai[#{d1}] * #{wr(n)}) <<< 24;"]
    end
end

64.times do |j|
    def wr(i)
        s = cos(i.to_f/32*PI)
        t = (s * (2**11)).floor
        return t;
    end

    def wi(i)
        s = -sin(i.to_f/32*PI)
        t = (s * (2**11)).floor
        return t;
    end
    print "#{wr(j)} #{wi(j)}"
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

# 6.times do |k|
#     # k段目
#     32.times do |i|
#         # i個目のバタフライ
#         a = i/(2**k)*(2**(k+1)) + i%(2**k)
#         b = i/(2**k)*(2**(k+1)) + i%(2**k) + 2**k
#         n = (i*32/2**k)%64
#         # 文を追加
#         butterflies += regs[a].butterflyWith(regs [b], n);
#         print "#{k}段目の butterfly: #{a} with #{b}, n = #{n}\n"
#     end
# end

6.times do |k|
    # k段目
    32.times do |i|
        # i個目のバタフライ
        a = i/(2**k)*(2**(k+1)) + i%(2**k)
        b = i/(2**k)*(2**(k+1)) + i%(2**k) + 2**k
        n = (i*32 / 2**k)%64
        # 文を追加
        butterflies += regs[a].butterflyWith(regs [b], n);
        print "#{k}段目の butterfly: #{a} with #{b}, n = #{n}\n"
    end
end


6.times do |k|
    print "assign ar#{k} = \n";
    state = 2;
    32.times do |i|
        print " state == #{state} ? " + butterflies[i*6+k][0] + " :"
        state += 1;
    end
    print "    0;\n"

    print "assign ai#{k} = \n";
    state = 2;
    32.times do |i|
        print " state == #{state} ? " + butterflies[i*6+k][1] + " :"
        state += 1;
    end
    print "    0;\n"

    print "assign br#{k} = \n";
    state = 2;
    32.times do |i|
        print " state == #{state} ? " + butterflies[i*6+k][2] + " :"
        state += 1;
    end
    print "    0;\n"

    print "assign bi#{k} = \n";
    state = 2;
    32.times do |i|
        print " state == #{state} ? " + butterflies[i*6+k][3] + " :"
        state += 1;
    end
    print "    0;\n"

    print "assign wr#{k} = \n";
    state = 2;
    32.times do |i|
        print " state == #{state} ? " + butterflies[i*6+k][4] + " :"
        state += 1;
    end
    print "    0;\n"

    print "assign wi#{k} = \n";
    state = 2;
    32.times do |i|
        print " state == #{state} ? " + butterflies[i*6+k][5] + " :"
        state += 1;
    end
    print "    0;\n"
end

state = 3;

32.times do |i|
    print "#{state}: begin\n"
    print "#{butterflies[i*6+0][0]} <= xr0; "
    print "#{butterflies[i*6+0][1]} <= xi0; "
    print "#{butterflies[i*6+0][2]} <= yr0; "
    print "#{butterflies[i*6+0][3]} <= yi0; \n"
    print "#{butterflies[i*6+1][0]} <= xr1; "
    print "#{butterflies[i*6+1][1]} <= xi1; "
    print "#{butterflies[i*6+1][2]} <= yr1; "
    print "#{butterflies[i*6+1][3]} <= yi1; \n"
    print "#{butterflies[i*6+2][0]} <= xr2; "
    print "#{butterflies[i*6+2][1]} <= xi2; "
    print "#{butterflies[i*6+2][2]} <= yr2; "
    print "#{butterflies[i*6+2][3]} <= yi2; \n"
    print "#{butterflies[i*6+3][0]} <= xr3; "
    print "#{butterflies[i*6+3][1]} <= xi3; "
    print "#{butterflies[i*6+3][2]} <= yr3; "
    print "#{butterflies[i*6+3][3]} <= yi3; \n"
    print "#{butterflies[i*6+4][0]} <= xr4; "
    print "#{butterflies[i*6+4][1]} <= xi4; "
    print "#{butterflies[i*6+4][2]} <= yr4; "
    print "#{butterflies[i*6+4][3]} <= yi4; \n"
    print "#{butterflies[i*6+5][0]} <= xr5; "
    print "#{butterflies[i*6+5][1]} <= xi5; "
    print "#{butterflies[i*6+5][2]} <= yr5; "
    print "#{butterflies[i*6+5][3]} <= yi5; "
    state += 1;
    print "\n    state <= #{state};\nend\n"
end


print "#{state}: begin\n"
64.times do |i|
    print "datar[#{regs[i].d}] <= datar[#{regs[i].i}];\n"
    print "datai[#{regs[i].d}] <= datai[#{regs[i].i}];\n"
end
state += 1;
print "\n    state <= #{state};\nend\n"


