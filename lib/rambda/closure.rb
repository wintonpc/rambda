module Rambda
  Closure = Struct.new(:body, :env, :formals, :lambda_exp)
  Transformer = Struct.new(:exp)
  Primitive = Struct.new(:var, :val)
  Sender = Struct.new(:method, :val)
end
