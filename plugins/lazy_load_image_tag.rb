# encoding: utf-8

# 生成延迟加载的img标签
module Jekyll
  class LazyLoadImageTag < Liquid::Tag
    @img = nil

    def initialize(tag_name, markup, tokens)
      attributes = ['class', 'data-original', 'width', 'height', 'title']

      if markup =~ /(?<class>\S.*\s+)?(?<data-original>(?:https?:\/\/|\/|\S+\/)\S+)(?:\s+(?<width>\d+))?(?:\s+(?<height>\d+))?(?<title>\s+.+)?/i
        @img = attributes.reduce({}) do |img, attr|
          img[attr] = $~[attr].strip if $~[attr]
          img
        end

        if /(?:"|')(?<title>[^"']+)?(?:"|')\s+(?:"|')(?<alt>[^"']+)?(?:"|')/ =~ @img['title']
          @img['title'] = title
          @img['alt']   = alt
        else
          @img['alt'] = @img['title'].gsub(/"/, '&#34;') if @img['title']
        end
        @img['class'].gsub!("/", '') if @img['class']
      end

      super
    end

    def render(context)
      if @img
        "<img #{ @img.collect { |k,v| "#{k}=\"#{v}\"" if v  }.join(" ") }>"
      else
        "Error processing input, expected syntax: {% lazy_img [class name(s)] [http[s]:/]/path/to/image [width [height]] [title text | \"title text\" [\"alt text\"]] %}"
      end
    end
  end
end

Liquid::Template.register_tag('lazy_img', Jekyll::LazyLoadImageTag)
