module ActionController
  class TestCase

    # Remove deprecated support to non-keyword arguments in ActionController::TestCase#process,
    # #get, #post, #patch, #put, #delete, and #head from Rails 5.1.
    #
    # Wrap ActionController::TestCase#get for Rails 4.
    # Expand hash keys (params, session, flash) and call ActionController::TestCase#get.
    def get(action, **args)
      args_hash = args.dup
      move_to_parent(args_hash, :params)
      move_to_parent(args_hash, :session)
      move_to_parent(args_hash, :flash)

      process(action, "GET", args_hash)
    end

    # Move specified hash to parent hash.
    def move_to_parent(hash, key)
      return unless hash.has_key?(key)

      hash.merge!(hash[key])
      hash.delete(key)
    end
  end
end