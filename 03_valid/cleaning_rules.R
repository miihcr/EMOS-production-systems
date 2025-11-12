
# remove unit-of-measure errors in currency data

if (total.rev/staff >= 1.5*median(total.rev/staff,na.rm=TRUE)){
  total.rev <- total.rev/1000
}

if (total.costs/staff >= 1.5*median(total.costs/staff,na.rm=TRUE)){
  total.costs <- total.costs/1000
}

if (profit/staff >= 1.5*median(profit/staff,na.rm=TRUE)){
  profit <- profit/1000
}

if (turnover/staff >= 1.5*median(turnover/staff,na.rm=TRUE)){
  turnover <- turnover/1000
}

if (staff.costs/staff >= 1.5*median(staff.costs/staff,na.rm=TRUE)){
  staff.costs <- staff.costs/1000
}


