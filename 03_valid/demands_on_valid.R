
# range restrictions
staff >= 0
total.rev >= 0
total.costs >= 0
turnover >= 0
staff.costs >= 0
other.rev >= 0
vat >= 0

# logical and accounting constraints
if (staff >= 1) staff.costs >= 1
turnover + other.rev == total.rev
total.rev - costs == profit

# subject matter constraints
profit <= 0.6*total.rev



