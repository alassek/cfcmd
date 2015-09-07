module CFcmd
  module Util
    TERABYTE = 1099511627776.0
    GIGABYTE = 1073741824.0
    MEGABYTE = 1048576.0
    KILOBYTE = 1024.0

    def self.number_to_human_size(num)
      case
      when num == 1 then "1 Byte"
      when num < KILOBYTE then "%d Bytes" % num
      when num < MEGABYTE then "%.2f KB" % (num / KILOBYTE)
      when num < GIGABYTE then "%.2f MB" % (num / MEGABYTE)
      when num < TERABYTE then "%.2f GB" % (num / GIGABYTE)
      else "%.1f TB" % (num / TERABYTE)
      end
    end

    def self.number_to_human(num)
      return "1 File" if num == 1
      num = num.to_s
      groups = []
      groups.unshift(num.slice!(-3..-1)) while num.length > 3
      groups.unshift(num)
      "#{ groups.join(',') } Files"
    end
  end
end
