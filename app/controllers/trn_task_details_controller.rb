class TrnTaskDetailsController < ApplicationController

    #一覧画面 表示のアクション
    def index
     
      #データの取得
      @tasks = TrnTaskDetail
        .by_kanryo(params[:end_flg])
        .paginate(page: params[:page], per_page: 5)
        .order('end_flg asc, end_ymd asc')
     
      #No列の開始No
      @grid_no = 1
     
      #params[:page]がNullまたは空ではない場合
      if params[:page].present?
        #開始No = ページ × ページングサイズ
        @grid_no = (params[:page].to_i - 1) * 5 + 1
      end
     
    end

    #照会画面 表示のアクション
    def show
    
      #idでTasksテーブルを取得
      @task = TrnTaskDetail.find(params[:id])
    
      #viewを表示（省略可）
      render "show"
    
    end

    #登録画面 表示のアクション
    def new
     
      #Tasksテーブルのスキーマでモデル（ActiveRecord）を作成
      @task = TrnTaskDetail.new
     
      #viewを表示（省略可）
      render "new"
     
    end

    #編集画面 表示のアクション
    def edit
     
      #idでタスクテーブルを取得
      @task = Task.find(params[:id])
     
      #期限に値がある場合、日付型から文字列へ変換
      if @task.kigen.present?
        @task.end_ymd = @task.kigen.strftime("%Y%m%d")
      end
     
    end

    #登録画面 登録ボタン押下時のアクション
    def create
     
      #POSTされた値を元にTasksテーブル登録用レコードを作成
      @task = TrnTaskDetail.new(task_params)
     
      #エラーチェック
      if @task.valid?
        #--------------
        #エラーがない場合
        #--------------
        if @task.end_ymd.present?
          @task.kigen = Date.new(
            @task.end_ymd[0..3].to_i,
            @task.end_ymd[4..5].to_i,
            @task.end_ymd[6..7].to_i)
        end
        @task.kanryo = false
     
        #更新（エラーチェックを行わない）
        @task.save(validate:false)
     
        #フラッシュ（一度きりのセッション）にメッセージを格納
        flash[:msg] = "登録しました。"
     
        #一覧画面へリダイレクト
        redirect_to tasks_path
      else
        #--------------
        #エラー時
        #--------------
        #登録画面のviewを再表示
        render "new"
      end
     
    end

    #編集画面 更新ボタン押下時のアクション
    def update
     
      #POSTされた値(id)からレコードを取得
      @task = Task.find(params[:id])
     
      #レコードをPOSTされた値(入力値)で上書き
      @task.assign_attributes(task_params)
     
      #エラーチェック
      if @task.valid?
        #--------------
        #エラーがない場合
        #--------------
        if @task.end_ymd.present?
          @task.kigen = Date.new(
            @task.end_ymd[0..3].to_i,
            @task.end_ymd[4..5].to_i,
            @task.end_ymd[6..7].to_i)
        end
     
        #更新（エラーチェックを行わない）
        @task.save(validate:false)
     
        #フラッシュ（一度きりのセッション）にメッセージを格納
        flash[:msg] = "編集しました。"
     
        #一覧画面へリダイレクト
        redirect_to tasks_path
      else
        #--------------
        #エラー時
        #--------------
        render "edit"
      end
    end

  #一覧画面 削除ボタン押下時のアクション
  def destroy
 
    #idでTasksテーブルを取得
    @task = Task.find(params[:id])
 
    #削除処理（delete文発行）
    @task.destroy
 
    #フラッシュ（一度きりのセッション）にメッセージを格納
    flash[:msg] = "削除しました。"
 
    #呼び出し元URLへリダイレクト
    redirect_to request.referer
 
  end
 
  #一覧画面 完了ボタン押下時のアクション
  def kanryo
 
    #idでTasksテーブルを取得
    @task = Task.find(params[:id])
 
    #kanryoにtrueをセット
    @task.kanryo = true
 
    #更新処理（update文発行）
    @task.save
 
    #呼び出し元URLへリダイレクト
    redirect_to request.referer
 
  end
    #------------------------------------------------------------------------------
    private
    #------------------------------------------------------------------------------
     
    #ストロングパラメータ（マスアサインメント脆弱性回避）
    def task_params
      params.require(:task).permit(
        :task_title,
        :task_detail,
        :end_ymd
      )
    end
end