//
//  TaskListView.swift
//  Boong-To-Do
//
//  Created by 황석현 on 6/13/24.
//

import SwiftUI

/**할일 추가 완료 시, 할일 목록을 보여주는 화면*/
struct TodoListView: View {
    
    @EnvironmentObject var viewModel: TodoViewModel
    @State var isPresented = false
    @State var addTaskIsPresented = false
    
    var body: some View {
        ZStack{
            Color.gray.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
                    // MARK: 미완료 할일 리스트
                    Section {
                        ForEach(viewModel.notCompleteTodos) { todo in
                            TaskListCell(todo: todo)
                                .sheet(isPresented: $isPresented, content: {
                                    TodoDetailView(todo: todo)
                                        .presentationDetents([.height(580)])
                                        .presentationDragIndicator(.visible)
                                })
                                .onChange(of: isPresented) { _, _ in
                                    viewModel.fetchTask()
                                }
                        }
                        // TaskDetailView 불러오기
                        .onTapGesture { isPresented.toggle() }
                        
                    } header: {
                        HStack {
                            Text("\(viewModel.notCompleteTodos.count)개의 할 일")
                            
                            Spacer()
                            
                            // TODO: 정렬 기능 구현하기(추후 개발)
                            Text("정렬")
                            Image(systemName: SystemImage.alignArrow.name)
                        }
                        .padding()
                    }
                    // MARK: 완료 할일 리스트
                    if !viewModel.completeTodos.isEmpty {
                        Section {
                            ForEach(viewModel.completeTodos) { todo in
                                TaskListCell(todo: todo)
                                    .sheet(isPresented: $isPresented, content: {
                                        VStack {
                                            TodoDetailView(todo: todo)
                                                .presentationDetents([.height(580)])
                                                .presentationDragIndicator(.visible)
                                                .onDisappear(perform: {
                                                    viewModel.fetchTask()
                                                })
                                        }
                                    })
                            }
                            .onTapGesture {
                                isPresented.toggle()
                            }
                        } header: {
                            HStack {
                                Text("완료")
                                
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    
                    Spacer()
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    // MARK: 할일 추가
                    Button(action: {
                        addTaskIsPresented.toggle()
                    }, label: {
                        ZStack {
                            Image(systemName: SystemImage.plus.name)
                                .resizable()
                                .frame(width: 23, height: 23)
                                .foregroundStyle(.white)
                                .frame(width: 48, height: 48)
                                .background(.black)
                                .clipShape(Circle())
                        }
                        .padding()
                    })
                    .sheet(isPresented: $addTaskIsPresented, content: {
                        // 할일 추가 화면 모달뷰
                        AddTaskView(addTodoModalViewIsPresented: $addTaskIsPresented)
                            .presentationDetents([.height(200)])
                            .presentationDragIndicator(.visible)
                    })
                }
            }
            
        }
    }
}

#Preview("TaskList") {
    TodoListView()
        .environmentObject(TodoViewModel())
}

struct TaskListCell: View {
    
    @EnvironmentObject var viewModel: TodoViewModel
    var todo: Todo
    
    var body: some View {
        HStack {
            Button {
                // 할일 완료 기능
                viewModel.todoHasDone(todo: todo)
                viewModel.fetchTask()
            } label: {
                if todo.finishedAt != nil {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundStyle(todo.finishedAt != nil ? .secondaryText.opacity(0.5) : .primaryText)
                } else {
                    Image(systemName: "square")
                }
            }
            
            
            Text(todo.title)
                .font(.system(size: 14))
                .foregroundStyle(todo.finishedAt != nil ? .secondaryText : .primaryText)
                .padding(.horizontal, 10)
            
            Spacer()
            
            Button(action: {}, label: {
                Label("\(todo.requiredTime)분", systemImage: SystemImage.clock.name)
                    .font(.system(size: 10))
                    .foregroundStyle(.black)
            })
            .frame(width: 50, height: 18)
            .background(.gray).opacity(0.3)
            .clipShape(.rect(cornerRadius: 4))
            
        }
        .padding(20)
        .background(todo.finishedAt != nil ? .secondaryText.opacity(0.1) : .white)
        .clipShape(.rect(cornerRadius: 12))
        .contextMenu {
            Button(role: .destructive) {
                viewModel.deleteTask(id: todo.id)
            } label: {
                Label("삭제하기", systemImage: "trash")
            }
        }
        .clipShape(.rect(cornerRadius: 12))
        .padding(.horizontal, 10)
    }
}

#Preview("TaskListCell") {
    TaskListCell(todo: Todo(title: "프리뷰", requiredTime: 15, createdAt: Date.now))
}