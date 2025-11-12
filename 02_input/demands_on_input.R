# Check that variables exist and that IDs are unique
variables := c(
  "id"
  , "size"
  , "incl.prob"
  , "staff"
  , "total.rev"
  , "total.costs"
  , "profit"
  , "turnover"
  , "staff.costs"
  , "other.rev"
  , "vat")

all(variables %in% names(.))
is_unique(id)

# check input data type
is.character(id)
is.character(size)
size %in% c("sc0","sc1","sc2","sc3")
is.numeric(incl.prob)
is.integer(staff)
is.integer(total.rev)
is.integer(total.costs)
is.integer(total.costs)
is.integer(turnover)
is.integer(staff.costs)
is.integer(other.rev)
is.integer(vat)





