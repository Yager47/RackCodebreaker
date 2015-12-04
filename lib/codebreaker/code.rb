module Codebreaker
  class Code
    include Enumerable
    LENGTH = 4

    def initialize(code = nil)
      if code
        unless code.is_a?(String) && code.size == 4 && code =~ /^[1-6]{4}/
          raise ArgumentError, 'code should be a string and contains 4 numbers between 1 and 6'
        end
        @code = code
      else
        @code = secret_code
      end
    end

    def ==(other_code)
      raise ArgumentError, 'compared object should be Code' unless other_code.is_a?(Code)
      @code == other_code.to_s
    end

    def [](index)
      @code[index_converter(index)]
    end

    def []=(index, value)
      @code[index_converter(index)] = value.to_s
    end

    def delete(number)
      @code.delete!(number)
    end

    def delete_first(number)
      @code[@code.index(number)] = ''
    end

    def each(&block)
      block ? @code.each_char(&block) : @code.to_enum
    end

    def each_with_index(&block)
      block ? @code.split('').each_with_index(&block) : @code.to_enum
    end

    def size
      LENGTH
    end
    alias :length :size

    def to_s
      "#{@code}"
    end

    private

    def secret_code
      result = ''
      @code ? result = @code : LENGTH.times { result << rand(1..6).to_s }
      result
    end

    def index_converter(index)
      case index.class.to_s
      when "Fixnum"
        raise IndexError, "index can't be bigger than #{LENGTH - 1}" unless index < LENGTH && index >= 0
        index
      when "String"
        raise IndexError, "member #{index} doesn't exist in code" unless @code.include?(index)
        @code.index(index)
      else
        raise IndexError, "wrong type of index"
      end
    end
  end
end