require 'sqlite3'
require 'json'

module IptWr

  class Database

    def initialize(db_name)
      @db = nil
      @db = SQLite3::Database.new(db_name)
    end

    def create
      raise 'Uninitialized' if @db.nil?
      @db.execute('CREATE TABLE IF NOT EXISTS NatRules (pubIp TEXT NOT NULL, privIp TEXT NOT NULL, pubPort INT NOT NULL, privPort INT NOT NULL, proto TEXT NOT NULL, ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP, Desc TEXT)')
    end

  end

end
