require 'pry'
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
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end 

    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id 
          self.update
        else
          sql = <<-SQL
          INSERT INTO dogs (name, breed) 
          VALUES (?, ?)
          SQL
    
          DB[:conn].execute(sql, self.name, self.breed)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
          self
        end
      end

    def self.create(new_dog)
        dog = Dog.new(name: new_dog[:name], breed: new_dog[:breed])
        dog.save
        dog
    end
    
    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

     def self.find_by_id(id)
      sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
      SQL
      dog_found = DB[:conn].execute(sql, id).flatten
      Dog.new(id: dog_found[0], name: dog_found[1], breed: dog_found[2])
   end

   def self.find_or_create_by(name:, breed:)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      if !dog.empty?
         dog_found = dog[0]
         dog = Dog.new(id: dog_found[0], name: dog_found[1], breed: dog_found[2])
      else
      dog = self.create(name: name, breed: breed)  
      end 
      dog
    end 

    def self.find_by_name(name)
      sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
      SQL
      dog_found = DB[:conn].execute(sql, name).flatten
      Dog.new(id: dog_found[0], name: dog_found[1], breed: dog_found[2])
    end 

    def update
      sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
    
end 

