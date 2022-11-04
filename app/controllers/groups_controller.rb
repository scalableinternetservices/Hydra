class GroupsController < ApplicationController
    def index
        @groups = Group.all
    end

    def show
        @group = Group.find(params[:id]) rescue not_found
        @group_user = GroupUser.where(group_id:params[:id])
        @posts = Post.where(groupid:params[:id])
    end

    def new
        @group = Group.new
    end

    def create
        begin
            user = User.find(group_params[:user_id].to_i)
        rescue
            flash.alert = "User not found."
            redirect_to new_group_path and return
        end

        @group = Group.new(groupname:group_params[:groupname],pic_url:group_params[:pic_url])

        if @group.save
            @group_user = GroupUser.new(group_id:@group.id,user_id:user.id)
            if @group_user.save
                redirect_to group_path(@group)
            else
                render :new, status: :unprocessable_entity
            end
        else
            render :new, status: :unprocessable_entity
        end
    end
    
    def edit
        @group = Group.find(params[:id]) rescue not_found
    end
  
    def update
        @group = Group.find(params[:id]) rescue not_found

        if @group.update(groupname:group_params[:groupname],pic_url:group_params[:pic_url])
            redirect_to @group
        else
            render :edit, status: :unprocessable_entity
        end
    end
  
    def destroy
        GroupUser.where(group_id:params[:id]).each do |group_user|
            group_user.destroy
        end
        Post.where(groupid:params[:id]).each do |post|
            post.destroy
        end
        @group = Group.find(params[:id]) rescue not_found
        @group.destroy
        redirect_to groups_path, status: :see_other
    end

    private
      def group_params
        params.require(:group).permit(:groupname, :pic_url, :user_id)
      end

end
