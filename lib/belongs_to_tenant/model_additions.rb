module BelongsToTenant
  module ModelAdditions
    def belongs_to_tenant(association, opts = {})
      cattr_accessor :tenant_key

      belongs_to association

      self.tenant_key = association

      foreign_key = :"#{association}_id"

      validates foreign_key, presence: true
      validates_with TenantValidator

      define_method "#{association}_id=" do |id|
        raise BelongsToTenant::TenantIsImmutable unless new_record?
        write_attribute(foreign_key, id)
      end

      define_method "#{association}=" do |record|
        raise BelongsToTenant::TenantIsImmutable unless new_record?
        super record
      end

      # useful for join models
      if default = opts[:default_through]
        before_validation(on: :create) do
          if send(foreign_key).nil?
            default_record = self.send(default)
            fk = default_record && default_record.send(foreign_key)
            self.send("#{foreign_key}=", fk)
          end
        end
      end
    end
  end
end