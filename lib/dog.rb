require_relative '../config/environment'

class Dog
  attr_accessor :name, :breed 
  attr_reader :id 
  
  def initialize(id: nil, name:, breed:)
    @id = id 
    @name = name 
    @breed = breed 
  end 
  
  def self.create_table
    sql = <<-SQL 
          CREATE TABLE IF NOT EXISTS dogs(
          id INTEGER PRIMARY KEY,
          name TEXT, 
          breed TEXT
          )
          SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end
  
  def save
    sql = <<-SQL
          INSERT INTO dogs(name,breed)
          VALUES(?,?)
          SQL
    DB[:conn].execute(sql,self.name,self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  
  def self.create(hash)
    dog = Dog.new(name: hash[:name],breed: hash[:breed])
    dog.save
  end
  
  def self.new_from_db(row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
    dog
  end
  
  def self.find_by_id(idy)
      sql = <<-SQL 
            SELECT * FROM dogs
            WHERE id = ?
            LIMIT 1 
            SQL
      DB[:conn].execute(sql,idy).collect do |row|
        self.new_from_db(row)
      end.first
    end
    
  def self.find_or_create_by(name:,breed:)
      sql = <<-SQL
            SELECT * FROM dogs 
            WHERE name = ?, breed = ?
            SQL
      dogfound = DB[:conn].execute(sql,name,breed)[0]
      if !dogfound.empty?
        newdog = Dog.new_from_db(dogfound)
      else 
        doghash = {name: => name, breed: => breed}
        self.create(doghash)
      end
        
  end
    
    
    
end