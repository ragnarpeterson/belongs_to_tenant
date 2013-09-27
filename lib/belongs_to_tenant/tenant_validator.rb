module BelongsToTenant
  class TenantValidator < ActiveModel::Validator
    def validate(record)
      tenant_association = record.class.tenant_key
      fk = :"#{tenant_association}_id"

      record.class.reflect_on_all_associations(:belongs_to).each do |a|
        attr = a.name

        next if attr == tenant_association

        value = record.send(attr)

        if value && value.send(fk) != record.send(fk)
          record.errors.add attr, 'association must belong to the same tenant'
        end
      end
    end
  end
end