defmodule P5 do
  import Matrex

  def givens_rotation(matrix) do
    dim=matrix[:rows]
    givens_rotation(matrix, 2, 1, matrix, Matrex.eye(dim))
  end
  def givens_rotation(matrix, i, j, acc_r, acc_q) do
    if(j < matrix[:rows]) do
      if(i <= matrix[:rows]) do
        value = matrix[i][j]
        if value != 0 do
          given_actual=calculate_givens_matrix(acc_r, i, j)
          IO.inspect(given_actual)
          IO.inspect(acc_r)
          IO.inspect(multiply_matrix(given_actual,acc_r))
          givens_rotation(matrix, i + 1, j, multiply_matrix(given_actual,acc_r), multiply_matrix(given_actual,acc_q))
        else
          givens_rotation(matrix, i+1, j, acc_r, acc_q)
        end
      end

      if(i > matrix[:rows]) do
        givens_rotation(matrix, j+2, j+1, acc_r, acc_q)
      end
    else
      q = matrix_t(acc_q)
      r = acc_r
      IO.inspect(q)
      IO.inspect(r)
    end
  end

  def calculate_givens_matrix(matrix, i, j) do
    filas=matrix[:rows]
    top=matrix[j][j]
    kill=matrix[i][j]
    hyp=:math.pow(:math.pow(top,2)+:math.pow(kill,2),1/2)
    cos=top/hyp
    sen=kill/hyp
    ans=Matrex.eye(filas)
    ans=Matrex.update(ans,i,i,fn x -> cos end)
    ans=Matrex.update(ans,j,j,fn x -> cos end)
    ans=Matrex.update(ans,i,j,fn x -> -sen end)
    Matrex.update(ans,j,i,fn x -> sen end)

  end

  def matrix_t(matrix) do
    transpose(matrix)
  end

  def multiply_matrix(matrix_1, matrix_2) do
    Matrex.dot(matrix_1,matrix_2)
  end
end
