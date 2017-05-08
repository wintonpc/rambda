module Rambda
  Closure = Struct.new(:body, :env, :formals, :lambda_exp)
  Transformer = Struct.new(:exp)
  Primitive = Struct.new(:var, :val)
  Sender = Struct.new(:method, :val)
  Void = :'%#void'
  AsyncExpr = Struct.new(:proc, :thread, :done, :value, :exception, :mutex, :vm_id)
end
