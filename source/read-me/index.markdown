---
layout: page
title: README
comments: true
sharing: false
footer: true
---

``` ruby About-Yuez.rb
# 关于乐正
class Yuez
  include Lucky

  attr_reader :name, :title, :description, :contact

  def name
    '乐正 Yuez'
  end

  def title
    'Web开发者'
  end

  def description
    [
      '此人比较无趣，对娱乐活动无爱。',
      '爱简洁的事物。',
      '前后端开发样样都经手，样样都不精通。',
      '珍惜时间，热爱生命。'
    ].join
  end

  def contact
    {
        email: 'zgs225@gmail.com',
       github: 'https://github.com/zgs225',
           ps: 'Talk is cheap, show me the code.'
    }
  end
end

module Lucky
  module InstanceMethods
    attr_reader :lover

    def lover
      'Lucky'
    end
  end

  self.included(receiver)
    receiver.send :include, InstanceMethods
  end
end
```
