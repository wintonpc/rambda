module Rambda
  Closure = Struct.new(:body, :env, :formals, :lambda_exp)
  Primitive = Struct.new(:var, :val)
  Sender = Struct.new(:method, :val)
end
