graylog2-resque
===============

This gem is a failure handler plugin for [Resque][0] that sends resque failures to [graylog2][1]

Install
-------

    gem install graylog2-resque
or add to your Gemfile 

To use
------

    Graylog2::Resque::FailureHandler.configure do |config|
      # required
      config.gelf_server = "server"
      config.gelf_port = "port"
      
      # optional
      # config.host = "myhost"
      # config.facility = "rails_worker_exceptions"
      # config.level = GELF::FATAL
      # config.max_chunk_size = 'LAN'
    end

Author
------

Matt Conway :: matt@conwaysplace.com :: @mattconway

Copyright
---------

Copyright (c) 2012 Matt Conway. See LICENSE for details.

[0]: http://github.com/defunkt/resque
[1]: http://graylog2.org


