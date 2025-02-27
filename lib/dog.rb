class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(data_hash)
        @name = data_hash[:name]
        @breed = data_hash[:breed]
        @id = data_hash[:id]
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
        );
        SQL
        
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs;
        SQL

        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?);
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(attr_hash)
        dog = Dog.new(attr_hash)
        dog.save
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id IS ?;
        SQL

        DB[:conn].execute(sql, id).map { |row| self.new_from_db(row) }.first
    end

    def self.new_from_db(db_row)
        dog = Dog.new(id: db_row[0], name: db_row[1], breed: db_row[2])
        dog
    end

    def self.find_or_create_by(name:, breed:)
        pooch = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?;", name, breed)
        if !pooch.empty?
            dog_info = pooch[0]
            pooch = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
        else
            pooch = self.create(name: name, breed: breed)
        end
        pooch
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        SQL

        DB[:conn].execute(sql, name).map { |row| self.new_from_db(row) }.first
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ? WHERE id = ?;
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

end