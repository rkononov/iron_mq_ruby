module IronMQ
  class Queues

    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def path(options={})
      path = "projects/#{@client.project_id}/queues"
      if options[:name]
        path << "/#{options[:name]}"
      end
      path
    end

    def list(options={})
      ret = []
      r1 = @client.get("#{path(options)}", options)
      #p r1
      res = @client.parse_response(r1)
      res.each do |q|
        #p q
        q = Queue.new(self, q)
        ret << q
      end
      ret
    end

    # options:
    #  :name => can specify an alternative queue name
    def get(options={})
      options[:name] ||= @client.queue_name
      res = @client.parse_response(@client.get("#{path(options)}"))
      return Queue.new(self, res)
    end

    # Update a queue
    # options:
    #  :name => if not specified, will use global queue name
    #  :subscriptions => url's to subscribe to
    def post(options={})
      options[:name] ||= @client.queue_name
      res = @client.parse_response(@client.post(path(options), options))
      res
      p res

    end


  end

  class Queue

    def initialize(queues, res)
      @queues = queues
      @data = res
    end

    def raw
      @data
    end

    def [](key)
      raw[key]
    end

    def id
      raw["id"]
    end

    def name
      raw["name"]
    end

    def size
      return raw["size"] if raw["size"]
      return @size if @size
      q = @queues.get(:name=>name)
      @size = q.size
      @size
    end

    def total_messages
      return raw["total_messages"] if raw["total_messages"]
      return @total_messages if @total_messages
      q = @queues.get(:name=>name)
      @total_messages = q.total_messages
      @total_messages
    end

    # def delete
    # @messages.delete(self.id)
    # end
  end

end

