module BelongsToTenant
  Error = Class.new(StandardError)
  TenantIsImmutable = Class.new(Error)
end