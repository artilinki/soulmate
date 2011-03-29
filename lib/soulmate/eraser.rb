module Soulmate

  class Eraser < Base

    def del(items)
      items_deleted = 0
      items.each_with_index do |item, i|
        id    = item["id"]
        term  = item["term"]
        score = item["score"]

        if id and term
          # delete the raw data stored in a separate key to reduce memory usage
          items_deleted += Soulmate.redis.hdel(database, id)

          prefixes_for_phrase(term).each do |p|
            Soulmate.redis.srem(base, p) # remove this prefix in a master set
            Soulmate.redis.zrem("#{base}:#{p}", id) # remove the id of this term in the index
          end

        end
        puts "removed #{i} entries" if i % 100 == 0 and i != 0
      end

      Soulmate.redis.del(cachebase)

      items_deleted
    end
  end
end