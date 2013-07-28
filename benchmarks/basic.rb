require 'benchmark'
require 'securerandom'
require 'active_support/json/encoding'
require File.join __FILE__, '..', '..', 'lib', 'sewer'

class BlogPost
  def initialize(hash)
    @hash = hash
  end

  def as_json(*args)
    @hash
  end

  def cache_key
    @hash[:id]
  end
end


$db = []

100_000.times do |i|
  $db.push BlogPost.new({
    id: i+1,
    title: SecureRandom.urlsafe_base64(rand(20...100)),
    body: SecureRandom.urlsafe_base64(rand(500...2000)),
    tags: Array.new(rand(0...5)){ SecureRandom.urlsafe_base64(rand(5...10)) },
    published: rand(2) == 0,
    author: {
      id: rand(0...20),
      name: SecureRandom.urlsafe_base64(rand(8...20)),
      admin: rand(2) == 0,
      post_count: rand(50...100)
    },
    deleted_at: nil
  })
end

def random_slice
  $db.slice(rand(0...10000), rand(5..50))
end

n = 10_000

ase = ActiveSupport::JSON::Encoding::Encoder.new

raise "The two encoder yields different results!" unless ase.encode($db.first) == Sewer.dump($db.first)

Benchmark.bm(16) do |x|
  GC.start

  x.report("AS::JSON")         { n.times { ase.encode random_slice } }

  GC.start

  x.report("Sewer (Cold)")     { n.times { Sewer.dump random_slice } }

  GC.start

  x.report("Sewer (Warmer)")   { n.times { Sewer.dump random_slice } }

  # Generate a cache entry for everything in the db
  $db.each { |post| Sewer.dump post }

  GC.start

  x.report("Sewer (Hot)")      { n.times { Sewer.dump random_slice } }

  Sewer.config.cache_store = Sewer::Cache::NullStore.new

  GC.start

  x.report("Sewer (No cache)") { n.times { Sewer.dump random_slice } }
end

require 'pry'
binding.pry